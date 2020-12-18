#! /bin/sh

project_dir=$(cd $(dirname $(dirname ${0})) && pwd)
cd $project_dir

GOOS=linux go build -ldflags="-s -w" -trimpath \
  -o bin/http/api \
  cmd/http/main.go

GOOS=linux go build -ldflags="-s -w" -trimpath \
  -o bin/cli/cli \
  cmd/cli/cli/main.go

upx bin/http/api bin/cli/cli
