#!/bin/bash

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <number1> <number2> <number3>"
	exit 1
fi
if [ "$1" -gt "$2" ] && [ "$1" -gt "$3" ]; then
	echo "$1"
elif [ "$2" -gt "$3" ]; then
	echo "$2"
else
	echo "$3"
fi

