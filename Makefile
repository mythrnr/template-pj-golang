ifndef VERBOSE
MAKEFLAGS += --silent
endif

command = help
compose_opts =
go_pkgdir ?= $(shell go env GOPATH)/pkg
overridefile ?= override
pkg ?= .
pwd = $(shell pwd)
release ?= testing
version ?= edge

.PHONY: build
build:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.build.yaml \
		build --parallel --progress plain --pull $(compose_opts)

.PHONY: build-container
build-container:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		--profile server --profile godoc \
		build --parallel --progress plain --pull $(compose_opts)

	docker build \
		-f ./docker/nginx/certs.Dockerfile \
		-t mythrnr/template-pj-golang:mkcert-development .

.PHONY: certs
certs:
	docker run --rm \
		--volume=$(pwd):/workdir \
		--volume=$(pwd)/docker/nginx/certs:/out \
		--env=COMMON_NAME=localhost \
		mythrnr/template-pj-golang:mkcert-development

.PHONY: clean
clean:
	rm -rf .cache/* .tmp/*

.PHONY: cli
cli:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		run --rm app go run main.go -- $(command)

.PHONY: cover
cover:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		run --rm app sh scripts/cover.sh

.PHONY: deploy
deploy:
	REF="master" \
	&& : "$${GITHUB_TOKEN?:GITHUB_TOKEN is required.}" \
	&& if [ "testing" = "$(release)" ]; then \
		REF="develop"; \
	fi \
	&& curl -X POST \
		-H "Authorization: token $${GITHUB_TOKEN}" \
		-H "Accept: application/vnd.github+json" \
		-H "Content-Type: application/json" \
        "https://api.github.com/repos/mythrnr/template-pj-golang/actions/workflows/****TODO:****/dispatches" \
		-d "{ \"ref\": \"$${REF}\", \"inputs\": { \"env\": \"$(release)\", \"version\": \"$(version)\" } }"

.PHONY: down
down:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		--profile server --profile godoc \
		down

.PHONY: fmt
fmt:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		run --no-deps app go fmt ./...

.PHONY: godoc
godoc:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose --profile godoc up --timestamps

.PHONY: integrate
integrate:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		run --rm app sh scripts/integrate.sh $(pkg)

.PHONY: lint
lint:
	docker pull golangci/golangci-lint:latest > /dev/null \
	&& mkdir -p .cache/golangci-lint \
	&& docker run --rm \
		-v $(go_pkgdir):/go/pkg \
		-v $(pwd):/app \
		-v $(pwd)/.cache:/root/.cache \
		-w /app \
		golangci/golangci-lint:latest golangci-lint run $(pkg)/...

name =

.PHONY: migrate
migrate:
	@if [ "$(name)" = "" ]; then \
		echo "Migration name is not set."; \
		echo "Exec 'make migrate name={your migration filename}'"; \
		exit 1; \
	fi

	cd docker \
	&& docker compose run --rm --no-deps app \
		migrate create -ext sql -dir migration/sql $(name) \

test_opt =

ifdef TEST
test_opt = -test
endif

.PHONY: migrate-exec
migrate-exec:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		run --rm app go run main.go -- migrate up $(test_opt)

.PHONY: migrate-rollback
migrate-rollback:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		run --rm app go run main.go -- migrate down $(test_opt) 1

.PHONY: mock
mock:
	docker pull vektra/mockery:latest > /dev/null
	docker run --rm \
		--entrypoint sh \
		-v $(go_pkgdir):/go/pkg \
		-v $(pwd):$(pwd) \
		-w $(pwd) \
		vektra/mockery:latest scripts/genmock.sh $(pkg)

.PHONY: nancy
nancy:
	docker pull sonatypecommunity/nancy:latest > /dev/null \
	&& go list -buildvcs=false -deps -json ./... \
	| docker run --rm -i sonatypecommunity/nancy:latest sleuth

.PHONY: pull
pull:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		--profile server --profile godoc \
		pull

.PHONY: push
push:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.build.yaml push

.PHONY: release
release:
	if [ "$(tag)" = "" ]; then \
		echo "tag name is required."; \
		exit 1; \
	fi \
	&& git tag $(tag) \
	&& git push origin $(tag)

.PHONY: serve
serve:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		--profile server\
		up --timestamps $(compose_opts)

.PHONY: spell-check
spell-check:
	docker pull ghcr.io/streetsidesoftware/cspell:latest > /dev/null \
	&& docker run --rm \
		-v $(pwd):/workdir \
		ghcr.io/streetsidesoftware/cspell:latest \
			--config .vscode/cspell.json "**"

.PHONY: test
test:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		run --rm app sh scripts/test.sh $(pkg)

.PHONY: test-json
test-json:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		run --rm app sh scripts/test.sh . -json

.PHONY: tidy
tidy:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker compose \
		-f compose.yaml \
		-f compose.$(overridefile).yaml \
		run --rm --no-deps app go mod tidy
