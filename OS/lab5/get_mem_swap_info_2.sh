#!/bin/bash

points="points_1"
log="log1"
if [[ -f $points ]]; then
	touch $points
fi

if [[ -f $log ]]; then
	touch $log
fi
echo "" > $points
echo "" > $log
term=0
cnt=10

while true; do
	if [[ "$term" -eq 1 ]]; then
		cnt=$((cnt-1))
	fi
	if [[ "$cnt" -eq "0" ]]; then
		break
	fi
	table=$(top -bn1)
	time=$(date | awk '{print $5}')
	mem_bash=$(grep "mem[2]*.bash" <<< $table)
	
	mem_free=$(echo "$table"| grep "МиБ Mem" | awk '{print $6}' | sed 's/,/\./')
	swap_free=$(echo "$table" | grep "МиБ Swap" | awk '{print $5}' | sed 's/,/\./')
	if (( $(echo "$swap_free <= 10.0" | bc -l) )); then
		if [[ -z "$mem_bash" ]]; then 
			term=1
		fi
	fi
	echo "$mem_free" >> $points
	echo "$swap_free" >> $points
	echo "$time" >> $points
	echo "$time" >> $log
	echo "$mem_bash" >> $log
	echo "$table" | head -n 12 >> $log
	
done

