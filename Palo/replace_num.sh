#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <filename> <replace_number> <team_number>"
    exit 1
fi

filename="$1"
replace_num="$2"
team_num="$3"

new_value=$((20 + team_num))

# Use sed to replace the number while preserving the file
sed -i "s/\b${replace_num}\b/${new_value}/g" "$filename"

echo "Successfully replaced all occurrences of '$replace_num' with '$new_value'"
