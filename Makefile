#Defaults
include .env
export #exports the .env variables

#Set DOCKER_IMAGE_VERSION in the .env file OR by passing in
VERSION ?= $(DOCKER_IMAGE_VERSION)
IMAGE ?= tulibraries/tul-spotlight
SOLR_IMAGE ?= tulibraries/tul-solr
SOLR_VERSION ?= 8.3.0
SOLR_URL ?= http://solr:8983/solr/blacklight-core	
HARBOR ?= harbor.k8s.temple.edu
CLEAR_CACHES ?= no
CI ?=
SPOTLIGHT_DB_HOST = host.docker.internal
SPOTLIGHT_DB_NAME ?= tupress
SPOTLIGHT_DB_USER ?= root false
DEFAULT_RUN_ARGS ?= -e "EXECJS_RUNTIME=Disabled" \
		-e "K8=yes" \
 		-e "DB_HOST=$(SPOTLIGHT_DB_HOST)" \
 		-e "DB_NAME=$(SPOTLIGHT_DB_NAME)" \
 		-e "DB_USER=$(SPOTLIGHT_DB_USER)" \
 		-e "DB_PASSWORD=$(SPOTLIGHT_DB_PASSWORD)" \
 		-e "DB_ROOT_PASSWORD=$(SPOTLIGHT_DB_ROOT_PASSWORD)" \
		-e "RAILS_ENV=production" \
		-e "RAILS_MASTER_KEY=$(RAILS_MASTER_KEY)" \
		-e "RAILS_SERVE_STATIC_FILES=yes" \
		-e "SOLR_URL=$(SOLR_URL)" \
		--rm -it

build:
	@docker build --build-arg RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) \
		--tag $(HARBOR)/$(IMAGE):$(VERSION) \
		--tag $(HARBOR)/$(IMAGE):latest \
		--file .docker/app/Dockerfile \
		--no-cache .

pull_db:
	@docker pull bitnami/mariadb:latest

build_solr:
	@docker build \
		--tag $(HARBOR)/$(SOLR_IMAGE):$(SOLR_VERSION) \
		--tag $(HARBOR)/$(SOLR_IMAGE):latest \
		--file .docker/solr/Dockerfile.solr \
		--no-cache .

run:
	@docker run --name=spotlight -d -p 127.0.0.1:3000:3000/tcp \
		$(DEFAULT_RUN_ARGS) \
		$(HARBOR)/$(IMAGE):$(VERSION)

run_db:
	@docker run --name=db -p 127.0.0.1:3306:3306 \
		-e MARIADB_ROOT_PASSWORD=$(SPOTLIGHT_DB_ROOT_PASSWORD) \
		-d bitnami/mariadb:latest

run_solr:
	@docker run --name=solr -d -p $(SOLR_PORT):8983 \
		$(HARBOR)/$(SOLR_IMAGE):$(SOLR_VERSION)

stop_db:
	@docker stop db 

start_solr:
	@docker start solr

stop_solr:
	@docker stop solr

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
