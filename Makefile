include .envrc

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

## confirm: confirm the action
confirm:
	@echo -n 'Are you sure? (y/n): ' && read ans && [ $$ans = "y" ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## server: run the cmd/api application
server:
	go run ./cmd/api

## psql: connect to the database using psql
psql:
	psql ${GREENLIGHT_DB_DSN}

## up: run the up migrations
up: confirm
	echo 'Running up migrations...'
	migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} up

## down: run the down migrations
down: confirm
	echo 'Running down migrations...'
	migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} down

## migration: create a new migration file
migration: confirm
	@echo 'Creating migration files for ${name}'
	migrate create -seq -ext=.sql -dir=./migrations ${name}

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #
audit:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...

## vendor: tidy and vendor dependencies
vendor:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor

# ==================================================================================== #
# BUILD
# ==================================================================================== #
## build: build the cmd/api application
current_time = $(shell date --iso-8601=seconds)
git_description = $(shell git describe --always --dirty)
linker_flags =  '-s -X main.buildTime=${current_time} -X main.version=${git_description}'
build:
	@echo 'Building cmd/api...'
	go build -ldflags=${linker_flags} -o=./bin/api ./cmd/api
	GOOS=linux GOARCH=amd64 go build -ldflags=${linker_flags} -o=./bin/api-linux-amd64 ./cmd/api

.PHONY: help server psql up down migration audit vendor build