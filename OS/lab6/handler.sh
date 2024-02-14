#!/bin/bash

if [ $# -ne 1 ]; then
    exit 1
fi
echo $1
file_number=$1
file_name="files/file$file_number"


if [ ! -f "$file_name" ]; then
    echo "File $file_name not found."
    exit 1
fi
line=$(cat "$file_name")
for num in $line; do
	new_num=$(($num * 2))
	echo -n "$new_num " >> "$file_name"
done
