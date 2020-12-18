#!/bin/sh

project_root=$(cd $(dirname $(dirname ${0})) && pwd)

# target directory
directory=$project_root${1:+/}$1
echo ${directory:=$project_root} > /dev/null

# create tmp shell
tmp_filename="/tmp/"$(cat /dev/urandom | LC_CTYPE=C tr -dc "abcdefghijkmnpqrstuvwxyz" | fold -w 16 | head -n 1)
echo "#!/bin/sh" >>$tmp_filename
chmod 700 $tmp_filename

#
# コマンドの書き込み
#
# @param $1 string 対象ディレクトリ
#
function write_shell() {
  echo "echo $1 && mockery -case=underscore -name=.* -dir $1 -output $1/mocks" >> $tmp_filename
  echo "echo $? >> /dev/null" >> $tmp_filename
}

#
# シェルの書き込みを再帰的に実行する処理
# モックのディレクトリは除外する
#
# @param $1 string 書き込みルートディレクトリ
#
function generate_shell() {
  if $(echo $1 | grep -e mocks -e integrate > /dev/null); then
    return
  fi

  ls $1/*.go >>/dev/null 2>&1
  exists=$?

  if [ "0" = "$exists" ]; then
    write_shell $1
  fi

  for d in $(ls $1); do
    if [ -d "${1}/${d}" ]; then
      generate_shell "${1}/${d}"
    fi
  done
}

cd $project_root
generate_shell $directory

sh $tmp_filename
sts=$?
rm -f $tmp_filename

exit $sts
