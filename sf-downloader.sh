#!/bin/bash

# A folder/file SourceForge downloader for bash shell
# Copyright (C) 2024  chickendrop89

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

SOURCE="$1";
OUTPUT_DIRECTORY="$(pwd)"

# Check if there is a second argument/parameter
if [ -n "$2" ]
    then OUTPUT_DIRECTORY="$2"
fi

case "$1" in
    *help*|*HELP*|"")
        echo "usage: sf-downloader.sh <sourceforge folder url> [output directory]";
        exit 1
        ;;
esac

urlDecode() {
    echo "${1//+/ //%/\\x}"
}

# Cut URL path into segments
cutUrl(){
    echo "$1" | rev | cut -d/ -f "$2" | rev
}

coloredOutput(){
    case $2 in
        "red")
            printf "\e[0;31m %s \e[0m \n" "$1" ;;
        "yellow")
            printf "\e[0;33m %s \e[0m \n" "$1" ;;
        "green")
            printf "\e[0;32m %s \e[0m \n" "$1" ;;
        "cyan")
            printf "\e[0;36m %s \e[0m \n" "$1" ;;
        *)
            printf "\n"
    esac
}

http_status_check(){
    SOURCE_STATUS=$(curl -o /dev/null -m 10 --silent --head --write-out '%{http_code}' "$SOURCE")

    case $SOURCE_STATUS in
        "200")
            coloredOutput "Source check returned a valid HTTP status code" "green"
        ;;
        "404")
            coloredOutput "Source check returned HTTP status code 404, the destination directory does not exist" "red"
            exit 1
        ;;
        *)
            coloredOutput "Source check returned an unusual HTTP status code ($SOURCE_STATUS). Not continuing" "red"
            exit 1
    esac
}

sourceforge_source_download(){
    REQUEST_URL=$(curl -m 300 -Ls "$SOURCE" | grep files_name_h | grep -o 'https://[^"]*')

    for DOWNLOAD_URL in $REQUEST_URL
        do
            # Cut the second segment from end, which should contain the filename
            REQUEST_FILENAME=$(cutUrl "$DOWNLOAD_URL" 2)
            REQUEST_FILENAME=$(urlDecode "$REQUEST_FILENAME")

            # Cut the third segment from end, which should contain the source directory
            REQUEST_DIRNAME=$(cutUrl "$DOWNLOAD_URL" 3)

            coloredOutput "Downloading $REQUEST_FILENAME from $REQUEST_DIRNAME" "cyan"
            curl "$DOWNLOAD_URL" \
                    --retry 3 --retry-all-errors \
                    --tcp-fastopen --create-dirs -m 120 -L -o \
            "$OUTPUT_DIRECTORY/$REQUEST_FILENAME"
            
            coloredOutput
    done
}


# Do a HTTP status check before downloading
http_status_check

# Download the SourceForge files
sourceforge_source_download
