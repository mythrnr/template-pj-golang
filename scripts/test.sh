#!/bin/bash

# define directories
scripts_dir=$(dirname "${0}")
project_dir=$(readlink -f "${scripts_dir}/..")

cd "${project_dir}" || exit 1

# remove slash
package=""
if [ "" != "${1}" ]; then
  tmp=$(echo "${1}" | tr -d '.')
  tmp="${tmp%*/}"
  package="${tmp#/}"
fi

# output as json
json=""
if [ "" != "${2}" ]; then
  json="-json"
fi

go list ./... | grep -v mocks | grep -v integrate > go.list

target=$(cat go.list)
if [ "" != "${package}" ]; then
  target=$(grep "${package}" < go.list)
fi

rm -rf go.list

# shellcheck disable=SC2086
go test -cover ${json} ${target}
sts=$?

if [ "0" = "$sts" ] && [ "" = "$json" ]; then
  echo "Testing successfully."
fi

exit $sts
