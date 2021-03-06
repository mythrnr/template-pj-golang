#!/bin/bash

# define directories
project_dir=$(cd $(dirname $(dirname ${0})) && pwd)
src_dir=`go env GOPATH`/src

cd $project_dir

# target directory
directory=$project_dir${1:+/}$1
echo ${directory:=$project_dir} > /dev/null

# remove slash
package=""
if [ "x" != "x${1}" ]; then
  tmp=$(echo ${1} | tr -d '.')
  tmp="${tmp%*/}"
  package="${tmp#/}"
fi

if [ "x" != "x${package}" ]; then
  go list ./${package}/... | grep -v mocks | grep -v integrate > go.list
else
  go list ./... | grep -v mocks | grep -v integrate > go.list
fi

target=`cat go.list`
rm -rf go.list

for d in ${target}; do
  dir="${src_dir}/${d}"
  if [ -d "${dir}" ]; then
    echo ${dir}

    rm -rf ${dir}/mocks

    mockery \
      --name=.* \
      --case=underscore \
      --dir ${dir} \
      --output ${dir}/mocks
  fi
done

exit 0
