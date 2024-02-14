#!/bin/bash

if [[ $# -ne 1 ]]; then
	exit 1
fi

exp(){
	local x="$1"
	local n=50
	local sum=1
	local tmp=1
	
	for (( i=1; i<=n; i++ )); do
		tmp=$(echo "scale=10; $tmp*$x/$i" | bc -l)
		sum=$(echo "scale=10; $sum+$tmp" | bc -l)
	done
	
	echo $sum
}
echo $(exp $1)
