#!/bin/bash

scripts_dir=$(dirname "${0}")
project_dir=$(readlink -f "${scripts_dir}/..")

cd "${project_dir}" || exit 1

GOOS=${GOOS:-linux}
APP_VERSION=${APP_VERSION?:required}
APP_REVISION=$(git rev-parse "${APP_VERSION}")

FLAGS="-s -w"
FLAGS="${FLAGS} -X github.com/mythrnr/template-pj-golang/config.Version=${APP_VERSION}"
FLAGS="${FLAGS} -X github.com/mythrnr/template-pj-golang/config.Revision=${APP_REVISION}"

GOOS=${GOOS} go build -trimpath -buildvcs=false -ldflags="${FLAGS}" -o bin/app main.go

upx bin/app
