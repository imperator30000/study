#!/bin/bash

top -bn1 | grep "МиБ Mem" | awk '{print $1 " "  $2  $3 " " $4 " total"}' | sed 's/,/\./'
top -bn1 | grep "МиБ Swap" | awk '{print $1 " "  $2  " " $3 " total" }' | sed 's/,/\./'
echo "Page size: "$(getconf PAGE_SIZE)
top -bn1 | grep "МиБ Mem" | awk '{print $1 " "  $2  $3 " " $6 " free"}' | sed 's/,/\./'
top -bn1 | grep "МиБ Swap" | awk '{print $1 " "  $2  " "$5 " free"}' | sed 's/,/\./'

