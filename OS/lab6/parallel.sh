#!/bin/bash

for (( i=1; i <= $1; i++ )); do
	./exp.sh $i &
done
wait
