#!/bin/bash

arr=()
i=0

while true; do
  arr+=(0 1 2 3 4 5 6 7 8 9)
  let i=$i+10
  if [[ $i -ge "$1" ]]; then
    exit 0
  fi
done
