#!/bin/bash

max_mem=0
pid_with_max_mem=-1
for pid in $(ps axo pid); do
    if [[ -f /proc/$pid/status ]]; then
        mem=$(awk '/VmSize:/ {print $2}' /proc/$pid/status)
        if [[ $mem -gt $max_mem ]]; then
            max_mem=$mem
            pid_with_max_mem=$pid
        fi
    fi
done
echo "PID: $pid_with_max_mem MAX: $max_mem kB"

echo
echo "top:"
echo
top -b -n 1 | head -n 7

x=$(top -b -n 1 | tail -n +8)
echo "$x" | sort -k5,5nr
 ps aeo pid=,vsz= | sort -k 2,2n | tail -n -1 | awk '{print $1 ":" $2}'
