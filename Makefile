.PHONY: build build-container clean cli cover godoc integrate lint mock pull push serve test test-json tidy version
.SILENT: test-json

command = help
compose_opts =
go_pkgdir ?= $(shell go env GOPATH)/pkg
go_version ?= 1.16
overridefile ?= override
pkg ?=

build:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.build.yml \
		build --parallel

build-container:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		build --parallel $(compose_opts)

clean:
	rm -rf .tmp .netrc .realize.yaml build/golang/.env docs/unit_tests

cli:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm cli go run cmd/cli/cli/main.go -- $(command)

cover:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/cover.sh

godoc:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose up docs godoc

integrate:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/integrate.sh $(pkg)

lint:
	cd deployments \
	&& \
	PKG=$(pkg) \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm --no-deps app golangci-lint run \
			--config=./.golangci.yml \
			--print-issued-lines=false $${PKG:-.}/...

mock:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose run --rm --no-deps app \
		sh scripts/genmock.sh $(pkg)

pull:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml pull

push:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.build.yml push

serve:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		up $(compose_opts) app cli database elasticsearch web

test:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/test.sh $(pkg)

test-json:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/test.sh . -json

tidy:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm --no-deps app go mod tidy

version:
	cd deployments \
	&& \
	GO_VERSION=$(go_version) \
	GO_PKGDIR=$(go_pkgdir) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm --no-deps app sh \
			-c 'cd cmd/cli/generator/version && go generate'
