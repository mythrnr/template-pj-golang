#!/bin/bash

# define directories
scripts_dir=$(dirname "${0}")
project_dir=$(readlink -f "${scripts_dir}/..")

cd "${project_dir}" || exit 1

# remove slash
package=""
if [ "x" != "x${1}" ]; then
  tmp=$(echo "${1}" | tr -d '.')
  tmp="${tmp%*/}"
  package="${tmp#/}"
fi

if [ "x" != "x${package}" ]; then
  go list -buildvcs=false "./integrate/${package}/..." | grep -v mocks > go.list
else
  go list -buildvcs=false ./integrate/... | grep -v mocks > go.list
fi

target=$(cat go.list)
rm -rf go.list

# shellcheck disable=SC2086
go test ${target}
sts=$?

if [ "0" = "$sts" ]; then
  echo "Testing successfully."
fi

exit $sts
