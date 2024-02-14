#!/bin/bash

#6300000
min=0
max=$1
result=0

while [ $min -le $max ]; do
	mid=$(( (min + max) / 2 ))
	echo "$mid"
	./start_newmem.sh $mid $2
	while top -bn1. | grep -q "newmem.bash"; do
		sleep 1
	done

	if dmesg | grep "newmem.bash"; then
		max=$(( mid - 1 ))
	else
		result=$mid
		min=$(( mid + 1 ))
	fi
	dmesg -c
	sleep 1
done

echo "$result"
#4292067

