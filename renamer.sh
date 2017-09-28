#!/usr/bin/env bash

set -e
set -u

die() { echo "$@" 1>&2 ; exit 1; }

usage() {
    echo "usage:"
    echo -e "\t./renamer.sh <filename>"
}

# TODO instead of dying, we should intelligently find the title
die_if_empty() {
    local str=$1
    local type=$2
    if [[ -z "${str// }" ]]; then
        die "Couldn't find $type"
    fi
}

if [ "$#" -ne 1 ]; then
    usage
    die "Incorrect number of arguments"
fi

pdf="$1"

if [ ! -f "$pdf" ]
then
    usage
    die "File $pdf does not exists"
fi

# get title, note that xargs is used to trim
title=$(pdfinfo "$pdf" | egrep '^Title' | sed 's/^Title:[[:space:]]*//g' |  head -c 60 | xargs | sed 's/[[:space:]]/-/g')
die_if_empty "$title" "title"

# get authors
IFS=',' read -ra names <<< "$(pdfinfo "$pdf" | egrep '^Author:[[:space:]]*' | sed 's/^Author:[[:space:]]*//g')"
author=$(echo "${names[0]}" | awk '{print $NF}')
die_if_empty "$author" "author"

# get year
year=$(pdfinfo "$pdf" | egrep '^CreationDate' | awk '{print $NF}')
die_if_empty "$year" "year"

filename="$(dirname "$pdf")/${year}_${author}_${title}.pdf"
mv "$pdf" "$filename"

