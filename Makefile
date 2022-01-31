command = help
compose_opts =
go_pkgdir ?= $(shell go env GOPATH)/pkg
overridefile ?= override
pkg ?= .
release ?= testing
version ?= edge

.PHONY: build
.SILENT: build
build:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.build.yaml \
		build --parallel --pull $(compose_opts)

.PHONY: build-container
.SILENT: build-container
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
.SILENT: certs
certs:
	docker run --rm \
		--volume=$(shell pwd):/workdir \
		--volume=$(shell pwd)/docker/nginx/certs:/out \
		--env=COMMON_NAME=localhost \
		mythrnr/template-pj-golang:mkcert-development

.PHONY: clean
.SILENT: clean
clean:
	rm -rf .tmp .netrc docker/app/.env docs/unit_tests

.PHONY: cli
.SILENT: cli
cli:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm app go run main.go -- $(command)

.PHONY: cover
.SILENT: cover
cover:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm app sh scripts/cover.sh

.PHONY: deploy
.SILENT: deploy
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
.SILENT: down
down:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml down

.PHONY: fmt
.SILENT: fmt
fmt:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --no-deps app go fmt ./...

.PHONY: godoc
.SILENT: godoc
godoc:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose up docs godoc

.PHONY: integrate
.SILENT: integrate
integrate:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm app sh scripts/integrate.sh $(pkg)

.PHONY: lint
.SILENT: lint
lint:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm --no-deps app golangci-lint run $(pkg)/...

.PHONY: mock
.SILENT: mock
mock:
	sh scripts/genmock.sh $(pkg)

.PHONY: pull
.SILENT: pull
pull:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml pull

.PHONY: push
.SILENT: push
push:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.build.yaml push

.PHONY: serve
.SILENT: serve
serve:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		up $(compose_opts)

.PHONY: test
.SILENT: test
test:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm app sh scripts/test.sh $(pkg)

.PHONY: test-json
.SILENT: test-json
test-json:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --rm app sh scripts/test.sh . -json

.PHONY: tidy
.SILENT: tidy
tidy:
	cd docker \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yaml \
		-f docker-compose.$(overridefile).yaml \
		run --no-deps app go mod tidy
