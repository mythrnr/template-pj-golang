#!/bin/bash

pid=0

function run () {
  if [ $pid -ne 0 ]; then
    kill -9 $pid
  fi

  go build -trimpath -buildvcs=false -o .tmp/app main.go \
    && chmod +x .tmp/app \
    && .tmp/app serve &

  pid=$!
}

function watch () {
  # shellcheck disable=SC2046
  inotifywait \
    --event create \
    --event delete \
    --event modify \
    --event move \
    --include "\.(go|yaml)$" \
    --monitor \
    --recursive $(ls)
}

run

while read -r f ; do
  echo "inotifywait detected the event: $f"

  run
done < <(watch)
