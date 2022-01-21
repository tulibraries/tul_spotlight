#Defaults
include .env
export #exports the .env variables

#Set DOCKER_IMAGE_VERSION in the .env file OR by passing in
VERSION ?= $(DOCKER_IMAGE_VERSION)
IMAGE ?= tulibraries/tul-spotlight
SOLR_IMAGE ?= tulibraries/tul-solr
SOLR_VERSION ?= 8.3.0
SOLR_URL = http://$(SOLR_HOST):$(SOLR_PORT)/solr/tul_spotlight
HARBOR ?= harbor.k8s.temple.edu
CLEAR_CACHES ?= no
CI ?= false
SPOTLIGHT_DB_HOST ?= host.docker.internal
SPOTLIGHT_DB_NAME ?= tul_spotlight
SPOTLIGHT_DB_USER ?= root
SPOTLIGHT_DB_PASSWORD ?= password
DEV_BUNDLE_PATH ?= vendor/bundle
CWD = $(shell pwd)
RAILS_MASTER_KEY?=137be8c5b0a917827949d83f80bd0d23

DEFAULT_RUN_ARGS ?= -e "EXECJS_RUNTIME=Disabled" \
    -e "K8=yes" \
    -e "SPOTLIGHT_DB_HOST=$(SPOTLIGHT_DB_HOST)" \
    -e "SPOTLIGHT_DB_NAME=$(SPOTLIGHT_DB_NAME)" \
    -e "SPOTLIGHT_DB_USER=$(SPOTLIGHT_DB_USER)" \
    -e "SPOTLIGHT_DB_PASSWORD=$(SPOTLIGHT_DB_PASSWORD)" \
    -e "SPOTLIGHT_DB_ROOT_PASSWORD=$(SPOTLIGHT_DB_ROOT_PASSWORD)" \
    -e "RAILS_ENV=production" \
    -e "RAILS_MASTER_KEY=$(RAILS_MASTER_KEY)" \
    -e "RAILS_SERVE_STATIC_FILES=yes" \
    -e "SOLR_URL=$(SOLR_URL)" \
    --rm -it

show-env:
	@echo "SOLR_HOST: $(SOLR_HOST)"
	@echo "SOLR_URL: $(SOLR_URL)"
	@echo "DB_HOST: $(SPOTLIGHT_DB_HOST)"
	@echo "RAILS_MASTER_KEY: $(RAILS_MASTER_KEY)"
	@echo "BUNDLE_PATH: $(DEV_BUNDLE_PATH)"
	@echo "CWD: $(CWD)"

build: pull_db build_solr build_app

build-app:
	@docker build --build-arg RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) \
		--tag $(HARBOR)/$(IMAGE):$(VERSION) \
		--tag $(HARBOR)/$(IMAGE):latest \
		--file .docker/app/Dockerfile \
		--no-cache .

pull-db:
	@docker pull bitnami/mariadb:latest

build-solr:
	@docker build \
		--tag $(HARBOR)/$(SOLR_IMAGE):$(SOLR_VERSION) \
		--tag $(HARBOR)/$(SOLR_IMAGE):latest \
		--file .docker/solr/Dockerfile.solr \
		--no-cache .

init-data: run_solr run_db

run-app:
	@docker run --name=spotlight -d -p 127.0.0.1:3000:3000/tcp \
		$(DEFAULT_RUN_ARGS) \
		$(HARBOR)/$(IMAGE):$(VERSION)

repl: build_app stop_app run_app

run-db:
	@docker run --name=db -d -p 127.0.0.1:3306:3306 \
	  -e MARIADB_ROOT_PASSWORD=$(SPOTLIGHT_DB_ROOT_PASSWORD) \
		bitnami/mariadb:latest

run-solr:
	@docker run --name=solr -d -p $(SOLR_PORT):8983 \
		$(HARBOR)/$(SOLR_IMAGE):$(SOLR_VERSION)

shell-app:
	@docker exec -it spotlight bash -l

start: start_solr start_db run_app

start-app:
	@docker start spotlight

start-db:
	@docker start db 

start-solr:
	@docker start solr

stop: stop-app stop-db stop-solr

stop-app:
	-docker stop spotlight

stop-db:
	-docker stop db 

stop-solr:
	-docker stop solr

reset-data: reset_db reset_solr

reset-db: down_db run_db

reset-solr: down_solr run_solr

down-all: down_app down_db down_solr

down-app: stop-app
	@docker rm app

down-db: stop-db
	@docker rm db 

down-solr: stop-solr
	@docker rm solr

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

zip:
	zip -r ~/solrconfig.zip . -x ".git*" \
		Gemfile Gemfile.lock "spec/*" "vendor/*" \
		Makefile ".circle*" "bin/*" LICENSE "README*" \
		docker-compose.yml

build-dev:
	@docker build --build-arg RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) \
		--build-arg RAILS_ENV=development \
		--tag $(IMAGE):$(VERSION)-dev \
		--tag $(IMAGE):dev \
		--file .docker/app/Dockerfile.dev \
		--no-cache .

run-dev:
	@docker run --name=spotlight-dev -p 127.0.0.1:3000:3000/tcp \
    $(DEFAULT_RUN_ARGS) \
		-e "BUNDLE_PATH=$(DEV_BUNDLE_PATH)" \
    -e "RAILS_ENV=development" \
    --mount type=bind,source=$(CWD),target=/app \
    $(IMAGE):dev sleep infinity

shell-dev:
	@docker run --rm -it \
    $(DEFAULT_RUN_ARGS) \
    -e "RAILS_ENV=development" \
    --mount type=bind,source=$(CWD),target=/app \
    --entrypoint=sh --user=root \
    $(IMAGE):dev

stop-dev:
	@docker stop spotlight-dev
