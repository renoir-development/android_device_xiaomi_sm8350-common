#!/bin/bash
#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

if [[ ! -f proprietary-files.txt ]]; then
    echo "proprietary-files.txt is not a file"
    exit
fi

# Create a temporary working directory
TMPDIR=$(mktemp -d)

# Ignore the line indicating the source of blobs.
# If the line does not contain "extracted from" it
# is assumed that the information is not provided.
if [[ $(head -n 1 proprietary-files.txt) == *"extracted from"* ]]; then
    tail -n +2 proprietary-files.txt > ${TMPDIR}/files.txt
    echo $(head -n 1 proprietary-files.txt) >> ${TMPDIR}/sorted_files.txt
    echo "" >> ${TMPDIR}/sorted_files.txt
else
    cp proprietary-files.txt ${TMPDIR}/files.txt
fi

# Make all section names unique
sed -i "s/# .*/&00unique/g" ${TMPDIR}/files.txt

# Get and sort the section
cat ${TMPDIR}/files.txt | grep "# " | sort > ${TMPDIR}/sections.txt

# Write the sorted sections to sorted_files.txt
while read section; do
    echo "${section}" >> ${TMPDIR}/sorted_files.txt
    sed -n "/${section}/,/^$/p" ${TMPDIR}/files.txt | sort | grep -v "# "* | sed '/^[[:space:]]*$/d' >> ${TMPDIR}/sorted_files.txt
    echo -en '\n' >> ${TMPDIR}/sorted_files.txt
done < ${TMPDIR}/sections.txt

# There is one new line too much
sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' ${TMPDIR}/sorted_files.txt

# Revert the unique section names
sed -i "s/00unique//g" ${TMPDIR}/sorted_files.txt

mv ${TMPDIR}/sorted_files.txt proprietary-files.txt

# Clear the temporary working directory
rm -rf "${TMPDIR}"
