#!/bin/bash

report="report2.log"
arr=()
i=0

while true; do
  arr+=(0 1 2 3 4 5 6 7 8 9)
  let i=$i+1
  if [[ $i -eq 100000 ]]; then
    echo "${#arr[*]}" > $report
    i=0
  fi
done
