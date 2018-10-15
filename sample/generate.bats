#!/usr/bin/env bats

# Uses the bash automated testing system to validate the metafile generation script
# https://github.com/bats-core/bats-core/

function get_command {
  CMD=$1
  REF=$2
  PATH=$(which $CMD || true)
  if [ "${PATH}" == "" ]
  then
    echo "no ${CMD} installed, see $REF" >&2
    exit 1 
  fi
  echo ${PATH}
}

JQ="$(get_command jq https://stedolan.github.io/jq/)"
MKTMP="$(get_command mktemp https://www.gnu.org/software/autogen/mktemp.html)"

setup() {
  export TMPDIR=$("${MKTMP}" -d)
}

teardown() {
  rm -rf ${TMPDIR}
}

@test "no table parameter" {
  run ${BATS_TEST_DIRNAME}/generate.sh
  [[ "$status" -gt 0 ]]
  [[ "${lines[0]}" = "usage: generate.sh <table-name> <directory-path> <file-prefix>" ]]
}

@test "no directory parameter" {
  run ${BATS_TEST_DIRNAME}/generate.sh TBL
  [[ "$status" -gt 0 ]]
  [[ "${lines[0]}" = "usage: generate.sh <table-name> <directory-path> <file-prefix>" ]]
}

@test "no file prefix" {
  run ${BATS_TEST_DIRNAME}/generate.sh TBL "${TMPDIR}"
  [[ "$status" -gt 0 ]]
  [[ "${lines[0]}" = "usage: generate.sh <table-name> <directory-path> <file-prefix>" ]]
}

@test "empty directory" {
  run ${BATS_TEST_DIRNAME}/generate.sh TBL "${TMPDIR}" empty
  [[ "$status" -gt 0 ]]
  [[ "${lines[0]}" = "error! ${TMPDIR} contains no files!" ]]
}

@test "contains just a directory" {
  mkdir ${TMPDIR}/empty.csv
  run ${BATS_TEST_DIRNAME}/generate.sh TBL "${TMPDIR}" empty
  [[ "$status" -gt 0 ]]
  [[ "${lines[0]}" = "error! ${TMPDIR} contains no files!" ]]
}

@test "contains just a symlink" {
  ln -s /proc/self/fd/0 ${TMPDIR}/stdin.csv
  run ${BATS_TEST_DIRNAME}/generate.sh TBL "${TMPDIR}" stdin
  [[ "$status" -gt 0 ]]
  [[ "${lines[0]}" = "error! ${TMPDIR} contains no files!" ]]
}

@test "no csv suffix" {
  echo "Woo" > ${TMPDIR}/file1
  run ${BATS_TEST_DIRNAME}/generate.sh TBL "${TMPDIR}" file
  [[ "$status" -gt 0 ]]
  [[ "${lines[0]}" = "error! ${TMPDIR} contains no files!" ]]
}

@test "one file with csv suffix non matching prefix" {
  echo "Woo" > ${TMPDIR}/file.csv
  run ${BATS_TEST_DIRNAME}/generate.sh TBL "${TMPDIR}" filename
  [[ "$status" -gt 0 ]]
  [[ "${lines[0]}" = "error! ${TMPDIR} contains no files!" ]]
}

@test "one file with exact csv suffix" {
  echo "Woo" > ${TMPDIR}/file.csv
  run ${BATS_TEST_DIRNAME}/generate.sh TBL "${TMPDIR}" file
  [[ "$status" -eq 0 ]]
}

@test "one file with numeric csv suffix" {
  TBL="TBL"
  FILE="file"
  echo "Woo" > ${TMPDIR}/${FILE}1.csv
  run ${BATS_TEST_DIRNAME}/generate.sh "${TBL}" "${TMPDIR}" "${FILE}"
  [[ "$status" -eq 0 ]]
  JSON="${TMPDIR}/${FILE}.meta.json"
  [[ "$(jq -r '.table_name' ${JSON})" == "${TBL}" ]]
  [[ "$(jq -r '.files|length' ${JSON})" == "1" ]]
  [[ "$(jq -r '.files[0].file_name' ${JSON})" == "${FILE}1.csv.gz" ]]
  [[ "$(jq -r '.files[0].line_count' ${JSON})" == "1" ]]
  MD5=$(md5sum ${TMPDIR}/${FILE}1.csv.gz | cut -f1 -d' ')
  [[ "$(jq -r '.files[0].md5sum' ${JSON})" == "${MD5}" ]]
}

@test "happy path" {
  TBL="PRODUCE"
  FILE="RK_PRODUCE_20170804_144259"
  echo "5721735,Grand Michel,Banana,Original and Best,Produce,Edible items,Fruit,fleshy seed-associated structures of a plant that are sweet or sour,Yellow,572173,77,active,1,,,2018-01-01 00:00:00,michel" > ${TMPDIR}/${FILE}.aaa.csv
  echo "5721723,Granny Smith,Apple,Crisp and Delicious,Produce,Edible items,Fruit,fleshy seed-associated structures of a plant that are sweet or sour,Green,572172,50,active,5,,,2018-01-01 00:00:00,granny" > ${TMPDIR}/${FILE}.aab.csv
  echo "5721724,Red Delicous,Apple,Soft and Sweet,Produce,Edible items,Fruit,fleshy seed-associated structures of a plant that are sweet or sour,Red,572172,355,active,3,,,2018-01-01 00:00:00,red" >> ${TMPDIR}/${FILE}.aab.csv
  run ${BATS_TEST_DIRNAME}/generate.sh "${TBL}" "${TMPDIR}" "${FILE}"
  [[ "$status" -eq 0 ]]
  JSON="${TMPDIR}/${FILE}.meta.json"
  [[ "$(jq -r '.table_name' ${JSON})" == "${TBL}" ]]
  [[ "$(jq -r '.files|length' ${JSON})" == "2" ]]
  [[ "$(jq -r '.files[0].file_name' ${JSON})" == "${FILE}.aaa.csv.gz" ]]
  [[ "$(jq -r '.files[0].line_count' ${JSON})" == "1" ]]
  MD5=$(md5sum ${TMPDIR}/${FILE}.aaa.csv.gz | cut -f1 -d' ')
  [[ "$(jq -r '.files[0].md5sum' ${JSON})" == "${MD5}" ]]
  [[ "$(jq -r '.files[1].file_name' ${JSON})" == "${FILE}.aab.csv.gz" ]]
  [[ "$(jq -r '.files[1].line_count' ${JSON})" == "2" ]]
  MD5=$(md5sum ${TMPDIR}/${FILE}.aab.csv.gz | cut -f1 -d' ')
  [[ "$(jq -r '.files[1].md5sum' ${JSON})" == "${MD5}" ]]
}

@test "space in path" {
  export SPACEDIR="${TMPDIR}/space in path"
  mkdir -p "${SPACEDIR}"
  TBL="PRODUCE"
  FILE="PRODUCE"
  echo "5721735" > "${SPACEDIR}/${FILE}.aaa.csv"
  run ${BATS_TEST_DIRNAME}/generate.sh "${TBL}" "${SPACEDIR}" "${FILE}"
  [[ "$status" -gt 0 ]]
}

@test "space in table name" {
  TBL="PROD UCE"
  FILE="PRODUCE"
  echo "5721735" > "${TMPDIR}/${FILE}.aaa.csv"
  run ${BATS_TEST_DIRNAME}/generate.sh "${TBL}" "${TMPDIR}" "${FILE}"
  [[ "$status" -gt 0 ]]
}

@test "space in file prefix" {
  TBL="PRODUCE"
  FILE="PROD UCE"
  echo "5721735" > "${TMPDIR}/${FILE}.aaa.csv"
  run ${BATS_TEST_DIRNAME}/generate.sh "${TBL}" "${TMPDIR}" "${FILE}"
  [[ "$status" -gt 0 ]]
}
