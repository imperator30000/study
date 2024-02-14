#!/bin/bash

HOME=/home/user
if [[ $# -ne 1 ]]; then
  echo "expected 1 argument , but found $# arguments"
  exit 1
fi

if [[ ! -f $1 ]]; then
  echo "$1 not found"
  exit 1
fi

old_name=$1
trash=$HOME/.trash/

if [[ ! -d $trash ]]; then
  mkdir $trash
fi

logs=$HOME/.trash.log

if [[ ! -f $logs ]]; then
  touch $logs
fi

cnt=0
sep="___"
date_time_now=$(date +"%Y-%m-%d_%H:%M:%S")
name=$cnt$sep$date_time_now$sep$old_name
while [[ -f $trash$name ]]; do
  let cnt=$cnt+1
  name=$cnt$sep$date_time_now$sep$old_name
done

ln $1 $trash$name
rm -f $1

echo $(realpath $1) $name >> $logs
