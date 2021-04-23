#! /bin/sh

project_dir=$(cd $(dirname $(dirname ${0})) && pwd)
cd $project_dir

GOOS=${GOOS:-linux}
APP_VERSION=${APP_VERSION?:required}
APP_REVISION=`git rev-parse ${APP_VERSION}`

FLAGS="-s -w"
FLAGS="${FLAGS} -X github.com/mythrnr/template-pj-golang.Version=${APP_VERSION}"
FLAGS="${FLAGS} -X github.com/mythrnr/template-pj-golang.Revision=${APP_REVISION}"

GOOS=${GOOS} go build -trimpath \
  -ldflags="${FLAGS}" \
  -o bin/http/api \
  cmd/http/main.go

GOOS=${GOOS} go build -trimpath \
  -ldflags="${FLAGS}" \
  -o bin/cli/cli \
  cmd/cli/cli/main.go

upx bin/http/api bin/cli/cli
