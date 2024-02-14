#!/bin/bash

fetch_val() {
  grep "$3" /proc/$1/$2 | awk '{print $NF}'
}

compute() {
  num1=$(fetch_val $1 sched sum_exec_runtime)
  num2=$(fetch_val $1 sched nr_switches)
  echo "$num1/$num2 + 0" | bc -l
}

for process in $(ps axo pid | grep -E '[0-9]+')
do
  if [[ -e /proc/$process/status ]]
  then
    echo ProcessID=$process : Parent_ProcessID=$(fetch_val $process status PPid) : Average_Time=$(compute $process)
  fi
done | sort -t '=' -k3,3n > result4.txt

