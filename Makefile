projectDir := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))
os := $(shell uname)
VERSION ?= $(shell git rev-parse --short HEAD)

# P2P tasks

.PHONY: local
local:
	docker-compose run --rm gradle_build sh -c 'gradle service:build'

.PHONY: stubbed-functional
stubbed-functional:
	docker-compose run --rm gradle_build sh -c 'gradle functional:clean functional:test'

.PHONY: stubbed-nft
stubbed-nft:
	@echo "Not implemented!"

.PHONY: integrated
integrated:
	@echo "Not implemented!"

.PHONY: extended-stubbed-nft
extended-stubbed-nft:
	@echo "Not implemented!"

# Custom tasks
.PHONY: run-local
run-local:
	docker-compose build service --no-cache
	docker-compose run --service-ports --rm service