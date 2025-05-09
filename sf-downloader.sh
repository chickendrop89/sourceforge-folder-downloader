#!/bin/bash

# A folder/file SourceForge downloader for bash shell
# Copyright (C) 2025 chickendrop89

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

SOURCE="$1"
OUTPUT_DIRECTORY="$(pwd)"

# Check if there is a second argument/parameter
if [ -n "$2" ]
    then OUTPUT_DIRECTORY="$2"
fi

case "$1" in
    *help*|*HELP*|"")
        echo "usage: sf-downloader.sh <sourceforge folder url> [output directory]"
        exit 1
        ;;
esac

# Wrapper for curl with common arguments
curl_common() {
    URL="$1"
    shift

    curl "$URL" \
        --retry 3 \
        --retry-all-errors \
        --compressed \
        --connect-timeout 15 \
        -L \
        "$@"
}

# Cut URL path into segments
cut_url(){
    echo "$1" | rev | cut -d/ -f "$2" | rev
}

colored_output() {
    MESSAGE="$1"
    COLOR="$2"

    case "$COLOR" in
        red)    printf "\033[31m%s\033[0m\n" "$MESSAGE"; exit 1 ;;
        yellow) printf "\033[33m%s\033[0m\n" "$MESSAGE" ;;
        green)  printf "\033[32m%s\033[0m\n" "$MESSAGE" ;;
        cyan)   printf "\033[36m%s\033[0m\n" "$MESSAGE" ;;
        *)      printf "\n" ;;
    esac
}

# Check HTTP status of source URL before proceeding
http_status_check() {
    SOURCE_STATUS=$(curl_common "$SOURCE" -o /dev/null -s --head --write-out '%{http_code}')
    
    case "$SOURCE_STATUS" in
        200)
            colored_output "Source check returned a valid HTTP status code" "green"
            ;;
        404)
            colored_output "Source check returned HTTP status code 404, the destination directory does not exist" "red"
            ;;
        *)
            colored_output "Source check returned an unusual HTTP status code ($SOURCE_STATUS). Not continuing" "red"
            ;;
    esac
}

sourceforge_source_download(){
    REQUEST_URL=$(curl_common "$SOURCE" -s | grep files_name_h | sed -n 's/.*\(https:[^"]*\).*/\1/p')

    if [ -z "$REQUEST_URL" ];
        then
            colored_output "Couldn't find any file names in this URL" "red"
    fi

    for DOWNLOAD_URL in $REQUEST_URL
        do
            # Cut the second segment from end, which should contain the filename
            REQUEST_FILENAME=$(cut_url "$DOWNLOAD_URL" 2)

            # Cut the third segment from end, which should contain the source directory
            REQUEST_DIRNAME=$(cut_url "$DOWNLOAD_URL" 3)

            colored_output "Downloading $REQUEST_FILENAME from $REQUEST_DIRNAME" "cyan"
            if ! curl_common "$DOWNLOAD_URL" \
                --create-dirs \
                --tcp-fastopen \
                -o "$OUTPUT_DIRECTORY/$REQUEST_FILENAME" 
                then
                    colored_output "Failed to download $REQUEST_FILENAME" "red"
            fi

        colored_output "Successfully downloaded $REQUEST_FILENAME" "green"
    done
}


# Do a HTTP status check before downloading
http_status_check

# Download the SourceForge files
sourceforge_source_download
