#!/bin/bash

for (( i=1; i <= $1; i++ )); do
	./handler.sh $i &
done
wait
