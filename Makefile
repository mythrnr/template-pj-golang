.PHONY: build build-container clean cli cover godoc integrate lint mock pull push serve test test-json tidy version
.SILENT: test-json

command = help
compose_opts =
go_pkgdir ?= $(shell go env GOPATH)/pkg
go_version ?= 1.15
overridefile ?= override
pkg ?=

build:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.build.yml \
		build --parallel

build-container:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		build --parallel $(compose_opts)

clean:
	rm -rf .tmp .netrc .realize.yaml build/golang/.env docs/unit_tests

cli:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm cli go run cmd/cli/cli/main.go -- $(command)

cover:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/cover.sh

godoc:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose up docs godoc

integrate:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/integrate.sh $(pkg)

lint:
	PKG=$(pkg) \
	&& GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm --no-deps app golangci-lint run \
			--config=./.golangci.yml \
			--print-issued-lines=false $${PKG:-.}/...

mock:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose run --rm --no-deps app \
		sh scripts/genmock.sh $(pkg)

pull:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml pull

push:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.build.yml push

serve:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		up $(compose_opts) app cli database elasticsearch web

test:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/test.sh $(pkg)

test-json:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app go test -cover -json ./...

tidy:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm --no-deps app go mod tidy

version:
	GO_VERSION=$(go_version) \
	&& GO_PKGDIR=$(go_pkgdir) \
	&& cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm --no-deps app sh \
			-c 'cd cmd/cli/generator/version && go generate'
