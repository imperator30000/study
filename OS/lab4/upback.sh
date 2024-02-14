#!/bin/bash

dir="/home/user"
restore="$dir/restore"
if [[ ! -d $restore ]]; then
 	mkdir $restore
fi
last_date=$(awk -F - '{print $2"-"$3"-"$4}' <<< `ls $dir | grep -E "^Backup-[0-9]{4}-[0-1][0-9]-[0-3][0-9]"` | sort | tail -n 1)
last_dir="$dir/Backup-$last_date"

if [[ $last_date == "--" ]]; then
	echo "Nothing to restore."
	exit 1
fi


for file in `ls $last_dir`; do
        if [[ $file =~ \.[0-9]{4}-[0-1][0-9]-[0-3][0-9]$ ]]; then
                echo ${file::-11}
        else
            	echo $file
        fi
done | sort | uniq | while read file; do
        cur=`ls $last_dir | grep "$file" | sort | tail -n 1`
        echo $file
        cp $last_dir/$cur $restore/$file
done
