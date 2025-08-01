#!/bin/sh

# A recursive sourceforge folder downloader for the linux shell 
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
OVERWRITE=false

# Check for overwrite flag in any position
for arg in "$@"; do
    case "$arg" in
        -ow|--overwrite)
            OVERWRITE=true
            ;;
    esac
done

SITE_ROOT="${SOURCE%%/projects/*}"
PROJECT=$(echo "$SOURCE" | sed -E 's|.*/projects/([^/]+).*|\1|')
PROJECT_FILES_ROOT="$SITE_ROOT/projects/$PROJECT/files/"
 
# Check if there is a second argument/parameter
if [ -n "$2" ]
    then OUTPUT_DIRECTORY="$2"
fi

case "$1" in
    *help*|*HELP*|"")
        echo "usage: sf-downloader.sh <sourceforge folder url> [output directory] [-ow, --overwrite]"
        exit 1
        ;;
esac

# Wrapper for curl with common arguments
curl_common() {(
    url="$1"
    shift

    curl "$url" \
        --retry 3 \
        --retry-all-errors \
        --compressed \
        --connect-timeout 15 \
        -L \
        "$@"
)}

# Cut URL path into segments
cut_url() {
    echo "$1" | rev | cut -d/ -f "$2" | rev
}

colored_output() {(
    message="$1"
    color="$2"

    case "$color" in
        red)    printf "\033[31m%s\033[0m\n" "$message"; exit 1 ;;
        yellow) printf "\033[33m%s\033[0m\n" "$message" ;;
        green)  printf "\033[32m%s\033[0m\n" "$message" ;;
        cyan)   printf "\033[36m%s\033[0m\n" "$message" ;;
        *)      printf "\n" ;;
    esac
)}

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

sourceforge_source_download() {(
    page_url="$1"
    sf_files_page_h="$(curl_common "$page_url" -s |
                    grep '<th scope="row" headers="files_name_h">')"
    download_urls=$(echo "$sf_files_page_h" |
                    sed -n 's|.*"\(https:[^"]*\).*|\1|p')
    subfolders=$(echo "$sf_files_page_h" | 
                    sed -n 's|.*"/projects/[^/]*/files/\([^"]*\).*|\1|p' |
                    grep -v '/latest/')

    if [ -z "$download_urls" ];
        then
            colored_output "Couldn't find any file names in this URL: $page_url" "yellow"
    fi

    for download_url in $download_urls
        do
            # Cut the second segment from end, which should contain the filename
            download_filename=$(cut_url "${download_url#"$SOURCE"}" 2)

            # Cut the third segment from end, which should contain the source directory
            download_dirname=$(cut_url "${download_url#"$SOURCE"}" 3-)

            # Get the relative directory name, in regard to the project's Files root directory
            download_dirname_from_root=$(cut_url "${download_url#"$PROJECT_FILES_ROOT"}" 3-)

            output_path="$OUTPUT_DIRECTORY/$download_dirname/$download_filename"
            
            # Skip if file exists and overwriting is not allowed
            if [ -f "$output_path" ] && [ "$OVERWRITE" = false ]; 
                then
                    colored_output "Skipping '$download_filename' - file already exists and overwriting is not allowed" "yellow"
                    continue
            fi

            if [ -z "$download_dirname_from_root" ];
                then colored_output "Downloading '$download_filename' from the root folder of project '$PROJECT'" "cyan"
                else colored_output "Downloading '$download_filename' from directory '$download_dirname_from_root' in project '$PROJECT'" "cyan"
            fi

            if ! curl_common "$download_url" \
                --create-dirs \
                --tcp-fastopen \
                -o "$output_path"
                then colored_output "Failed to download '$download_filename'" "red"
            fi

        colored_output "Successfully downloaded '$download_filename'" "green"
    done

    for subfolder in $subfolders
        do
            sourceforge_source_download "$SOURCE/$subfolder"
    done
)}


# Do a HTTP status check before downloading
http_status_check

# Download the SourceForge files
sourceforge_source_download "$SOURCE"
