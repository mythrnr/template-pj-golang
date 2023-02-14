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

go list ./... | grep -v mocks | grep -v integrate > go.list

target=$(cat go.list)
if [ "x" != "x${package}" ]; then
  target=$(grep "${package}" < go.list)
fi

rm -rf go.list

for d in ${target}; do
  dir=$(readlink -f "${project_dir}/../../../${d}")

  if [ -d "${dir}" ]; then
    echo "${dir}"

    rm -rf "${dir}/mocks"
    mockery \
      --name=.* \
      --case=underscore \
      --dir "${dir}" \
      --output "${dir}/mocks"
  fi
done

exit 0
