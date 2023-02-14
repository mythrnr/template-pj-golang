#!/bin/bash

# define directories
scripts_dir=$(dirname "${0}")
project_dir=$(readlink -f "${scripts_dir}/..")
src_dir=$(readlink -f "${project_dir}/../../..")
doc_dir="${project_dir}/docs/unit_tests"

# create tmp shell
# cspell:disable-next-line
tmp_filename="/tmp/"$(LC_CTYPE=C tr -dc "abcdefghijkmnpqrstuvwxyz" < /dev/urandom | fold -w 16 | head -n 1)
echo "#!/bin/bash" >> "${tmp_filename}"
chmod 700 "${tmp_filename}"

# カバレッジの index.html 出力用
pkglinks=""

#
# コマンドの書き込み
#
# @param $1 string 対象ディレクトリ
#
function write_shell() {
  dir=${1/$project_dir/$doc_dir}
  html="${dir}/index.html"
  markdown="${dir}/README.md"
  outfile="${dir}/cover.out"
  pkg=${1#"${src_dir}"/}

  cat <<-EOF >> "${tmp_filename}"
{
  mkdir -p "${dir}"
  {
    echo "# Coverage of ${pkg}"
    echo ""
    echo "| File | Line | Func | Coverage |"
    echo "| ---- | ----: | ---- | ----: |"
  } > "${markdown}"
  go test -coverprofile="${outfile}" "${pkg}" \\
  && go tool cover -html="${outfile}" -o "${html}" \\
  && go tool cover -func="${outfile}" |
    tr -s '\t' |
    tr '\t' '|' |
    sed -E "s/:(\d+):/\|\1/g" |
    sed "s/total:/total\|/g" |
    sed "s/^/\|/g" |
    sed "s/$/\|/g" >> "${markdown}"
}
EOF

  pkglinks="${pkglinks}<li><a href=\"/unit_tests/${pkg}\">${pkg}</a></li>"
}

#
# シェルの書き込みを再帰的に実行する処理
# モックのディレクトリは除外する
#
# @param $1 string 書き込みルートディレクトリ
#
function generate_shell() {
  if echo "${1}" | grep -e mocks -e integrate > /dev/null; then
    return
  fi

  ls "${1}"/*.go >> /dev/null 2>&1
  exists=$?

  if [ "0" = "$exists" ]; then
    write_shell "${1}"
  fi

  for d in "${1}"/*; do
    if [ -d "${d}" ]; then
      generate_shell "${d}"
    fi
  done
}

cd "${project_dir}" || exit 1
generate_shell "${project_dir}"

echo "echo 'Testing successfully.'" >> "${tmp_filename}"

sh "${tmp_filename}"
sts=$?
rm -f "${tmp_filename}"

# replace contents.
content="<div id=\"content\"><style>a{color: white;}</style><ul>${pkglinks}</ul>"
sed -i "s|<div id=\"content\">|$content|" "$doc_dir/index.html"

exit $sts
