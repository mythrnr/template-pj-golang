#!/bin/bash

# define directories
project_dir=$(cd $(dirname $(dirname ${0})) && pwd)

cd $project_dir

# remove slash
package=""
if [ "x" != "x${1}" ]; then
  tmp=$(echo ${1} | tr -d '.')
  tmp="${tmp%*/}"
  package="${tmp#/}"
fi

if [ "x" != "x${package}" ]; then
  go list ./integrate/${package}/... | grep -v mocks > go.list
else
  go list ./integrate/... | grep -v mocks > go.list
fi

target=`cat go.list`
rm -rf go.list

go test ${target}
sts=$?

if [ "x0" = "x$sts" ]; then
  echo "Testing successfully."
fi

exit $sts
