#!/bin/bash

if [[ $# -ne 1 ]]; then
	exit 1
fi

factorial(){
	if [ $1 -le 1 ]; then
		echo 1
	else
		local tmp=$(($1 - 1))
		local res=$(factorial $tmp)
		echo $(( $1 * res ))
	fi
}

res=$(factorial $1)
echo $res
