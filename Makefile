.PHONY: build build-container clean cli cover godoc integrate lint mock pull push serve test tidy version

command = help
compose_opts =
overridefile ?= override
target ?= .
lint_target ?= ./...

build:
	cd deployments \
	&& docker-compose \
		-f docker-compose.build.yml \
		build --parallel

build-container:
	cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		build --parallel $(compose_opts)

clean:
	rm -rf .tmp .netrc .realize.yaml build/golang/.env docs/unit_tests

cli:
	cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm cli go run cmd/cli/cli/main.go -- $(command)

cover:
	cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/cover.sh $(target)

godoc:
	cd deployments \
	&& docker-compose up docs

integrate:
	cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/integrate.sh $(target)

lint:
	cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm --no-deps app golangci-lint run \
			--config=./.golangci.yml \
			--print-issued-lines=false $(lint_target)

mock:
	cd deployments \
	&& docker-compose run --rm --no-deps app \
		sh scripts/genmock.sh $(target)

pull:
	cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml pull

push:
	cd deployments \
	&& docker-compose \
		-f docker-compose.build.yml push

serve:
	cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		up $(compose_opts) app cli database elasticsearch web

test:
	cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm app sh scripts/test.sh $(target)

tidy:
	cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm --no-deps app go mod tidy

version:
	cd deployments \
	&& docker-compose \
		-f docker-compose.yml \
		-f docker-compose.$(overridefile).yml \
		run --rm --no-deps app sh \
			-c 'cd cmd/cli/generator/version && go generate'
