ifndef VERBOSE
MAKEFLAGS += --silent
endif

command = help
go_pkgdir ?= $(shell go env GOPATH)/pkg
overridefile ?= override
pkg ?= .
pwd = $(shell pwd)
release ?= testing
version ?= edge

compose_global_opts = -f docker/compose.yaml -f docker/compose.$(overridefile).yaml --progress plain
compose_opts =

.PHONY: build
build:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose -f docker/compose.build.yaml --progress plain \
		build --pull $(compose_opts)

.PHONY: build-container
build-container:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server --profile godoc \
		build --pull $(compose_opts)

	docker build \
		--progress plain \
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
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server \
		run --rm app go run main.go -- $(command)

.PHONY: cover
cover:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server \
		run --rm app bash scripts/cover.sh

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
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server --profile godoc \
		down

.PHONY: fmt
fmt:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server \
		run --no-deps app go fmt ./...

.PHONY: godoc
godoc:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile godoc up

.PHONY: hadolint
hadolint:
	docker pull hadolint/hadolint:latest > /dev/null \
	&& find ./docker -name Dockerfile | xargs -I{} sh -c "\
		echo 'Run hadolint: {}' \
		&& docker run --rm -i -v $(shell pwd):/workdir -w /workdir \
			hadolint/hadolint < {}"

.PHONY: integrate
integrate:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server \
		run --rm app bash scripts/integrate.sh $(pkg)

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

	docker compose $(compose_global_opts) --profile server \
		run --rm --no-deps app \
			migrate create -ext sql -dir migration/sql $(name) \

test_opt =

ifdef TEST
test_opt = -test
endif

.PHONY: migrate-exec
migrate-exec:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server \
		run --rm app go run main.go -- migrate up $(test_opt)

.PHONY: migrate-rollback
migrate-rollback:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server \
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
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server --profile godoc \
		pull

.PHONY: push
push:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose -f docker/compose.build.yaml push

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
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server \
		up $(compose_opts)

.PHONY: spell-check
spell-check:
	docker pull ghcr.io/streetsidesoftware/cspell:latest > /dev/null \
	&& docker run --rm -v $(pwd):/workdir \
		ghcr.io/streetsidesoftware/cspell:latest \
			--config .vscode/cspell.json "**"

.PHONY: test
test:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server \
		run --rm app bash scripts/test.sh $(pkg)

.PHONY: test-json
test-json:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server \
		run --rm app bash scripts/test.sh . -json

.PHONY: tidy
tidy:
	GO_PKGDIR=$(go_pkgdir) \
	docker compose $(compose_global_opts) --profile server \
		run --rm --no-deps app go mod tidy
