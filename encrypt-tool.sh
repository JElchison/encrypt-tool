#!/bin/bash

# encrypt-tool.sh
#
# Bash script to encrypt/decrypt arbitrary files using OpenSSL. Useful for maintaining encrypted versions of files in the cloud (such as Dropbox), such that local plaintext edits never appear in Dropbox's "previous versions" history.
#
# Version 1.0.2
#
# Copyright (C) 2014 Jonathan Elchison <JElchison@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


# setup Bash environment
set -euf -o pipefail

#######################################
# Prints script usage to stderr
# Arguments:
#   None
# Returns:
#   None
#######################################
print_usage() {
    echo "Usage: $0 encrypt <plaintextFile> [outputDir]" >&2
    echo "       $0 decrypt <encryptedFile> <outputFile>" >&2
}

# ensure have all dependencies
if [[ ! -x $(which openssl) ]] || [[ ! -x $(which shred) ]] || [[ ! -x $(which gzip) ]] || [[ ! -x $(which zcat) ]]; then
    echo "[-] Dependencies unmet.  Please verify that the following are installed and in the PATH:  openssl, shred, gzip, zcat" >&2
    exit 1
fi

# check for number of arguments
if [[ $# -lt 2 ]] || [[ $# -gt 3 ]]; then
    print_usage
    exit 1
fi

# setup variables for arguments
COMMAND="$1"
INPUT_FILE="$2"

# test existence of input file
if [[ ! -e "$INPUT_FILE" ]]; then
    echo "[-] Input file '$INPUT_FILE' does not exist." >&2
    exit 1
fi

# switch on command
if [[ "$COMMAND" == "encrypt" ]]; then

    # handle optional argument
    if [[ $# == 3 ]]; then
        OUTPUT_DIR="$3"
    else
        OUTPUT_DIR="$(pwd)"
    fi

    # test existence of output directory
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        echo "[-] Output directory '$OUTPUT_DIR' does not exist." >&2
        exit 1
    fi

    # setup output file path, name
    OUTPUT_FILE=$(basename "$INPUT_FILE" | sed -r 's/\.[^\.]+$/.bin/')
    OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_FILE"

    # compress and encrypt
    gzip -c "$INPUT_FILE" | openssl aes-256-cbc -salt -out "$OUTPUT_PATH"
    # shred the input file
    shred -fuvz "$INPUT_FILE"
    # report success
    echo "[*] '$INPUT_FILE' has been encrypted and shredded.  Encrypted file exists at '$OUTPUT_PATH'."

elif [[ "$COMMAND" == "decrypt" ]]; then

    # decryption requires 3rd argument
    if [[ $# != 3 ]]; then
        print_usage
        exit 1
    fi

    # setup output filename
    OUTPUT_FILE="$3"

    # decrypt and decompress
    openssl aes-256-cbc -d -in "$INPUT_FILE" | zcat > "$OUTPUT_FILE"
    # report success
    echo "[*] '$INPUT_FILE' has been decrypted.  Plaintext file exists at '$OUTPUT_FILE'."

else
    echo "[-] Unknown command '$COMMAND'." >&2
    print_usage
    exit 1
fi
