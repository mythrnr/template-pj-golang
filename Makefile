ifndef VERBOSE
MAKEFLAGS += --silent
endif

command = help
compose_opts =
go_pkgdir ?= $(shell go env GOPATH)/pkg
overridefile ?= override
pkg ?= .
release ?= testing
version ?= edge

.PHONY: build
build:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.build.yaml \
		build --parallel --pull $(compose_opts)

.PHONY: build-container
build-container:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		build --parallel --pull $(compose_opts)

	docker build \
		-f ./docker/nginx/certs.Dockerfile \
		-t mythrnr/template-pj-golang:mkcert-development .

.PHONY: certs
certs:
	docker run --rm \
		--volume=$(shell pwd):/workdir \
		--volume=$(shell pwd)/docker/nginx/certs:/out \
		--env=COMMON_NAME=localhost \
		mythrnr/template-pj-golang:mkcert-development

.PHONY: clean
clean:
	rm -rf .tmp .netrc docker/app/.env docs/unit_tests

.PHONY: cli
cli:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm app go run main.go -- $(command)

.PHONY: cover
cover:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm app sh scripts/cover.sh

.PHONY: deploy
deploy:
	REF="master" \
	&& : "$${GITHUB_TOKEN?:GITHUB_TOKEN is required.}" \
	&& if [ "testing" = "$(release)" ]; then \
		REF="develop"; \
	fi \
	&& curl -X POST -H "Authorization: token $${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github.everest-preview+json" \
        "https://api.github.com/repos/mythrnr/template-pj-golang/actions/workflows/****TODO:****/dispatches" \
		-d "{ \"ref\": \"$${REF}\", \"inputs\": { \"env\": \"$(release)\", \"version\": \"$(version)\" } }"

.PHONY: down
down:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml down

.PHONY: fmt
fmt:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --no-deps app go fmt ./...

.PHONY: godoc
godoc:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose up docs godoc

.PHONY: integrate
integrate:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm app sh scripts/integrate.sh $(pkg)

.PHONY: lint
lint:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm --no-deps app golangci-lint run $(pkg)/...

name =

.PHONY: migrate
migrate:
	@if [ "$(name)" = "" ]; then \
		echo "Migration name is not set."; \
		echo "Exec 'make migrate name={your migration filename}'"; \
		exit 1; \
	fi

	cd docker \
	&& docker-compose run --rm --no-deps app \
		migrate create -ext sql -dir migration/sql $(name) \

.PHONY: migrate-exec
migrate-exec:
	cd docker \
	&& docker-compose exec app .tmp/app migrate up

.PHONY: migrate-rollback
migrate-rollback:
	cd docker \
	&& docker-compose exec app .tmp/app migrate down 1

.PHONY: mock
mock:
	sh scripts/genmock.sh $(pkg)

.PHONY: nancy
nancy:
	go list -json -m all | nancy sleuth

.PHONY: pull
pull:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml pull

.PHONY: push
push:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.build.yaml push

.PHONY: serve
serve:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		up $(compose_opts)

.PHONY: spell-check
spell-check:
	# npm install -g cspell@latest
	cspell lint --config .vscode/cspell.json ".*"; \
	cspell lint --config .vscode/cspell.json "**/.*"; \
	cspell lint --config .vscode/cspell.json ".{github,vscode}/**/*"; \
	cspell lint --config .vscode/cspell.json ".{github,vscode}/**/.*"; \
	cspell lint --config .vscode/cspell.json "**"

.PHONY: test
test:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm app sh scripts/test.sh $(pkg)

.PHONY: test-json
test-json:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm app sh scripts/test.sh . -json

.PHONY: tidy
tidy:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm --no-deps app go mod tidy
