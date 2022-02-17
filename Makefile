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

show_env:
	@echo "SOLR_HOST: $(SOLR_HOST)"
	@echo "SOLR_URL: $(SOLR_URL)"
	@echo "DB_HOST: $(SPOTLIGHT_DB_HOST)"
	@echo "RAILS_MASTER_KEY: $(RAILS_MASTER_KEY)"
	@echo "BUNDLE_PATH: $(DEV_BUNDLE_PATH)"
	@echo "CWD: $(CWD)"

build:
	@docker build --build-arg RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) \
		--tag $(HARBOR)/$(IMAGE):$(VERSION) \
		--tag $(HARBOR)/$(IMAGE):latest \
		--file .docker/app/Dockerfile \
		--no-cache .

pull+db:
	@docker pull bitnami/mariadb:latest

build_solr:
	@docker build \
		--tag $(HARBOR)/$(SOLR_IMAGE):$(SOLR_VERSION) \
		--tag $(HARBOR)/$(SOLR_IMAGE):latest \
		--file .docker/solr/Dockerfile.solr \
		--no-cache .

init_data: run_solr run_db

run_app:
	@docker run --name=spotlight -d -p 127.0.0.1:3000:3000/tcp \
		$(DEFAULT_RUN_ARGS) \
		$(HARBOR)/$(IMAGE):$(VERSION)

app_cli:
	@docker run -p 127.0.0.1:3000:3000/tcp --rm -it \
    $(DEFAULT_RUN_ARGS) \
		--user=root \
		$(HARBOR)/$(IMAGE):$(VERSION) bash -l

repl: build_app stop_app run_app

run_db:
	@docker run --name=db -d -p 127.0.0.1:3306:3306 \
	  -e MARIADB_ROOT_PASSWORD=$(SPOTLIGHT_DB_ROOT_PASSWORD) \
		bitnami/mariadb:latest

run_solr:
	@docker run --name=solr -d -p $(SOLR_PORT):8983 \
		$(HARBOR)/$(SOLR_IMAGE):$(SOLR_VERSION)

shell_app:
	@docker exec -it spotlight bash -l

start: start_solr start_db run_app

start_app:
	@docker start spotlight

start_db:
	@docker start db 

start_solr:
	@docker start solr

stop: stop_app stop_db stop_solr

stop_app:
	-docker stop spotlight

stop_db:
	-docker stop db 

stop_solr:
	-docker stop solr

reset_data: reset_db reset_solr

reset_db: down_db run_db

reset_solr: down_solr run_solr

down_all: down_app down_db down_solr

down_app: stop_app
	@docker rm app

down_db: stop_db
	@docker rm db 

down_solr: stop_solr
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
			trivy $(HARBOR)/$(IMAGE):$(VERSION); \
		fi
	@if [ $(CI) == false ]; \
		then \
			trivy image $(HARBOR)/$(IMAGE):$(VERSION); \
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

build_dev:
	@docker build --build-arg RAILS_MASTER_KEY=$(RAILS_MASTER_KEY) \
		--build-arg RAILS_ENV=development \
		--tag $(IMAGE):$(VERSION)-dev \
		--tag $(IMAGE):dev \
		--file .docker/app/Dockerfile.dev \
		--no-cache .

run_dev:
	@docker run --name=spotlight-dev -d \
		-p 127.0.0.1:3000:3000/tcp \
    $(DEFAULT_RUN_ARGS) \
    -e "BUNDLE_PATH=$(DEV_BUNDLE_PATH)" \
    -e "RAILS_ENV=development" \
    --mount type=bind,source=$(CWD),target=/app \
    $(IMAGE):dev sleep infinity

shell_dev:
	@docker exec -it spotlight-dev bash -l

stop_dev:
	-docker stop spotlight-dev
