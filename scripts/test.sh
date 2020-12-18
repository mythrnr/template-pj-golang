#!/bin/sh

# define directories
project_dir=$(cd $(dirname $(dirname ${0})) && pwd)
src_dir=$(dirname $(dirname $(dirname ${project_dir})))

# remove slash
package=""
if [ "x" != "x${1}" ]; then
  tmp=$(echo ${1} | tr -d '.')
  tmp="${tmp%*/}"
  package="${tmp#/}"
fi

# for multi process test
parallel=16

# create tmp shell
tmp_filename="/tmp/"$(cat /dev/urandom | LC_CTYPE=C tr -dc "abcdefghijkmnpqrstuvwxyz" | fold -w 16 | head -n 1)
echo "#!/bin/sh" >>$tmp_filename
chmod 700 $tmp_filename

#
# コマンドの書き込み
#
# @param $1 string 対象パッケージ
#
function generate_shell() {
  pkg=$1
  if [ "x" != "x$pkg" ]; then
    pkg=" | grep ${pkg}"
  fi

  cat <<EOF >>$tmp_filename
go test -cover -parallel ${parallel} \
  \$(go list ./... | grep -v mocks | grep -v integrate ${pkg})
sts=\$?

if [ "x0" = "x\$sts" ]; then
  echo "Testing successfully."
fi

exit \$sts
EOF
}

cd $project_dir
generate_shell $package

sh $tmp_filename
sts=$?
rm -f $tmp_filename

exit $sts
