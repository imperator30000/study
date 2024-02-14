#!/bin/bash

./4.sh
last_ppid=0
s=0
count=0
while read -r line
do
  cur_ppid=$(awk -F'[:=]' '{print $4}' <<< "$line")
  art=$(awk -F'[:=]' '{print $6}' <<< "$line")
  if [[ $last_ppid -ne $cur_ppid ]]
  then
    avg=$(echo "$s/$count" | bc -l)
    echo "Average_Running_Children_of_ParentID=$last_ppid is $avg"
    s=0
    count=0
    last_ppid=$cur_ppid
  fi
  s=$(echo "$s+$art" | bc -l)
  count=$((count+1))
  echo $line
done < result4.txt > result5.txt
if [[ $count -ne 0 ]]
then
  avg=$(echo "$s/$count" | bc -l)
  echo "Average_Running_Children_of_ParentID=$$cur_ppid is $avg" >> result5.txt
fi
