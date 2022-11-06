projectDir := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))
os := $(shell uname)
VERSION ?= $(shell git rev-parse --short HEAD)
registry = chbatey/reference-service

# P2P tasks

.PHONY: local
local: build local-stubbed-functional local-stubbed-nft

.PHONY: build
build:
	docker compose run --rm gradle_build sh -c 'gradle service:build'

.PHONY: local-stubbed-functional
local-stubbed-functional:
	rm -rf db-data
	docker compose build service downstream database --no-cache
	docker compose up -d service downstream database
	docker compose run --rm gradle_build sh -c 'gradle functional:clean functional:test'
	docker compose down

.PHONY: local-stubbed-nft
local-stubbed-nft:
	rm -rf db-data
	docker compose build service downstream database --no-cache
	docker compose up -d database downstream service
	docker compose run --rm k6 run ./nft/ramp-up/test.js
	docker compose down

.PHONY: stubbed-functional
stubbed-functional:
	docker compose run --rm gradle_build sh -c 'gradle functional:clean functional:test'

.PHONY: stubbed-nft
stubbed-nft:
	docker compose run --rm k6 run ./nft/ramp-up/test.js

.PHONY: extended-stubbed-nft
extended-stubbed-nft:
	@echo "Not implemented!"

.PHONY: integrated
integrated:
	@echo "Not implemented!"

# Custom tasks
.PHONY: run-local
run-local:
	docker compose build service downstream --no-cache
	docker compose up -d downstream
	docker compose run --service-ports --rm service

# Minikube local tasks
.PHONY: docker-build
docker-build:
	docker build --file Dockerfile.service --tag $(registry) .

.PHONY: docker-push
docker-push:
	docker push $(registry)
