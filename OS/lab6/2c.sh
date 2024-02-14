#!/bin/bash

log=2.log

echo "" > $log

for (( n=1; n<=20; n++ )); do
	echo "$n : " >> $log
	for (( i=0; i<10; i++ )); do
		{ \time -f "%E" ./2a.sh $n; } 1>>.trash 2>>$log
	done
done
