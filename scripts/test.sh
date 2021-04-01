#!/bin/sh

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

go list ./... | grep -v mocks | grep -v integrate > go.list

target=`cat go.list`
if [ "x" != "x${package}" ]; then
  target=`cat go.list | grep ${package}`
fi

rm -rf go.list

go test -cover ${target}
sts=$?

if [ "x0" = "x$sts" ]; then
  echo "Testing successfully."
fi

exit $sts
