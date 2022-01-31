#!/bin/bash

project_dir=$(cd $(dirname $(dirname ${0})) && pwd)
cd $project_dir

GOOS=${GOOS:-linux}
APP_VERSION=${APP_VERSION?:required}
APP_REVISION=`git rev-parse ${APP_VERSION}`

FLAGS="-s -w"
FLAGS="${FLAGS} -X github.com/mythrnr/template-pj-golang/config.Version=${APP_VERSION}"
FLAGS="${FLAGS} -X github.com/mythrnr/template-pj-golang/config.Revision=${APP_REVISION}"

GOOS=${GOOS} go build -trimpath -ldflags="${FLAGS}" -o bin/app main.go

upx bin/app
