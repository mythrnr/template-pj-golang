.PHONY: build build-container clean cli cover deploy down fmt godoc integrate lint mock pull push serve test test-json tidy
.SILENT: test-json

command = help
compose_opts =
go_pkgdir ?= $(shell go env GOPATH)/pkg
overridefile ?= override
pkg ?= .
release ?= testing
version ?= edge

build:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.build.yml \
		build --parallel $(compose_opts)

build-container:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		build --parallel $(compose_opts)

clean:
	rm -rf .tmp .netrc .realize.yaml build/app/.env docs/unit_tests

cli:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm cli go run cmd/cli/cli/main.go -- $(command)

cover:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/cover.sh

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

down:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml down --volumes

fmt:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --no-deps app go fmt ./...

godoc:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose up docs godoc

integrate:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/integrate.sh $(pkg)

lint:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm --no-deps app golangci-lint run $(pkg)/...

mock:
	sh scripts/genmock.sh $(pkg)

pull:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml pull

push:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.build.yml push

serve:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		up $(compose_opts) app cli database elasticsearch web

test:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/test.sh $(pkg)

test-json:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/test.sh . -json

tidy:
	cd deployments \
	&& \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --no-deps app go mod tidy
