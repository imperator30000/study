#!/bin/bash

output="result1.txt"
data=$(ps ax -u $USER -o pid,cmd | grep '\d\+' | awk '{print $1 ":" $2}')
echo "$data" | wc -l > $output
echo "$data" | awk '{print $1}' >> $output
