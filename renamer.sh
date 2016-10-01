#!/usr/bin/env bash

set -x
set -e
set -u

# TODO: provide usage

die() { echo "$@" 1>&2 ; exit 1; }

pdf="$1"

if [ ! -f "$pdf" ]
then
    die "File $pdf does not exists"
fi

# get title, note that xargs is used to trim
title=$(pdfinfo "$pdf" | egrep '^Title' | sed 's/^Title:\s*//g' |  head -c 60 | xargs | sed 's/\s/-/g')

# get authors
IFS=',' read -ra names <<< "$(pdfinfo "$pdf" | egrep '^Author:\s*' | sed 's/^Author:\s*//g')"
author=$(echo "${names[0]}" | awk '{print $NF}')

# get year
year=$(pdfinfo "$pdf" | egrep '^CreationDate' | awk '{print $NF}')

filename="$(dirname "$pdf")/${year}_${author}_${title}.pdf"
mv "$pdf" "$filename"

