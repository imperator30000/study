#!/bin/bash


line=""
while true; do
	read -r input
	if [[ "$input" == "q" ]]; then
		break
	fi
	line="$line$input"
done

echo "$line"
