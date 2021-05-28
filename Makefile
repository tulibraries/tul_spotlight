#Defaults
include .env
export #exports the .env variables

#Set DOCKER_IMAGE_VERSION in the .env file OR by passing in
VERSION ?= $(DOCKER_IMAGE_VERSION)
IMAGE ?= tulibraries/spotlight
HARBOR ?= harbor.k8s.temple.edu
CLEAR_CACHES ?= no
RAILS_MASTER_KEY ?= $(SPOTLIGHT_MASTER_KEY)
CI ?= false
DEFAULT_RUN_ARGS ?= -e "EXECJS_RUNTIME=Disabled" \
		-e "K8=yes" \
		-e "RAILS_ENV=production" \
		-e "RAILS_MASTER_KEY=$(RAILS_MASTER_KEY)" \
		-e "RAILS_SERVE_STATIC_FILES=yes" \
		--rm -it

build:
	@docker build --build-arg RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) \
		--tag $(HARBOR)/$(IMAGE):$(VERSION) \
		--tag $(HARBOR)/$(IMAGE):latest \
		--file .docker/app/Dockerfile \
		--no-cache .

run:
	@docker run --name=spotlight -p 127.0.0.1:3000:3000/tcp \
		$(DEFAULT_RUN_ARGS) \
		$(HARBOR)/$(IMAGE):$(VERSION)

lint:
	@if [ $(CI) == false ]; \
		then \
			hadolint .docker/app/Dockerfile; \
		fi

shell:
	@docker run --rm -it \
		$(DEFAULT_RUN_ARGS) \
		--entrypoint=sh --user=root \
		$(HARBOR)/$(IMAGE):$(VERSION)

load-data:
	@docker run --name=spotlight-sync\
		--entrypoint=/bin/sh\
		$(DEFAULT_RUN_ARGS) \
		$(HARBOR)/$(IMAGE):$(VERSION) -c 'rails sync:pressworks:all[press.xml]'

scan:
	@if [ $(CLEAR_CACHES) == yes ]; \
		then \
			trivy image -c $(HARBOR)/$(IMAGE):$(VERSION); \
		fi
	@if [ $(CI) == false ]; \
		then \
			trivy $(HARBOR)/$(IMAGE):$(VERSION); \
		fi

deploy: scan lint
	@docker push $(HARBOR)/$(IMAGE):$(VERSION) \
	# This "if" statement needs to be a one liner or it will fail.
	# Do not edit indentation
	@if [ $(VERSION) != latest ]; \
		then \
			docker push $(HARBOR)/$(IMAGE):latest; \
		fi
