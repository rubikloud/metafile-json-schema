#!/bin/bash -e

# This script is designed to work with CSV dumps that have been split with split(1)
# First parameter is the name of the table that these files should be loaded into
# Second parameter is the directory path location of the split files
# Third parameter is the prefix that is shared between the split files
# It will search the specified path for matching csv files, take a note of the number of lines
# compress them, checksum the compressed file and then write out a file with the results in the form of
# <directory-path>/<file-prefix>.json
# Then the compressed files can be uploaded Rubikloud
# Then the json file can be uploaded to Rubikloud

TABLE=$1
DIR=$2
PREFIX=$3

if [[ "${TABLE}" == "" || "${DIR}" == "" || "${PREFIX}" == "" ]]
then
    echo "usage: generate.sh <table-name> <directory-path> <file-prefix>"
    exit 1
fi

check_param() {
  if [[ $(echo "${2}" | grep -E "^[${3}]*$") == "" ]]
  then
    echo "$1 contains illegal characters"
    exit 1
  fi
}

check_param "table-name" "${TABLE}" 'A-Z'
check_param "directory-path" "${DIR}" 'a-zA-Z0-9_\/\.'
check_param "file-prefix" "${PREFIX}" 'a-zA-Z0-9_\/\.'

FILES=$(find "${DIR}" -type f -name "${PREFIX}*.csv")

if [ "${FILES}" == "" ]
then
    echo "error! ${DIR} contains no files!"
    exit 1
fi

cat <<EOH > "${DIR}/${PREFIX}.meta.json"
{
    "version": "1.0",
    "table_name": "${TABLE}",
    "files": [
EOH
for FILE in ${FILES}
do
    echo -n "${FIRST}" >> "${DIR}/${PREFIX}.meta.json"
    FIRST=","
    LINES=$(wc -l "${FILE}" | cut -f1 -d' ')
    gzip --best "${FILE}"
    CHECKSUM=$(md5sum "${FILE}.gz" | cut -f1 -d' ')
    cat <<EOF >> "${DIR}/${PREFIX}.meta.json"
    {
        "file_name": "${FILE##*/}.gz",
        "line_count": ${LINES},
        "md5sum": "${CHECKSUM}"
    }
EOF
done
echo "]}" >> "${DIR}/${PREFIX}.meta.json"

exit 0
