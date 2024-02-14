#!/bin/bash

if [ $# -eq 0 ]; then
    	echo "Usage: $0 <number of files>"
	exit 1
fi

n=$1
cnt=$2

if [ -d files ]; then
	rm -rf files
fi
mkdir -p files


for ((i=1; i<=n; i++)); do
    	filename="files/file$i"
    	> "$filename"
    	for ((j=0; j<cnt; j++)); do
        	echo -n $((RANDOM % 10))" " >> "$filename"
    	done
done
