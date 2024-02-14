#!/bin/bash

get_sizes() {
  for pid in $(ps axo pid | grep '[0-9]\+')
  do
    if [[ -f /proc/$pid/io ]]
    then
      size=$(awk '/read_bytes:/ {print $2}' /proc/$pid/io)
      echo ${size:-0} $pid
    fi
  done
}

get_sizes | sort -k2,2 > start

sleep 60

get_sizes | sort -k2,2 > end


join -1 2 -2 2 start end | awk '{print $1, $2, $3-$2}' | sort -k3,3nr | head -n 3 | while read pid start end; do
  echo "$pid:$(ps -o command= -p $pid):$end"
done

rm end start

