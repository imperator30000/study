#!/bin/bash

dir="/home/user"
source="$dir/source"
report="$dir/backup-report"
if [[ ! -f $report ]]; then
  touch $report
fi


now_date=`date +%Y-%m-%d`
last_date=$(awk -F - '{print $2"-"$3"-"$4}' <<< `ls $dir | grep "^Backup-[0-9]\{4\}-[0-1][0-9]-[0-3][0-9]$"` | sort | tail -n 1)
let ok=$(date +%s -d $now_date)-7*24*60*60
let last=$(date +%s -d $last_date)
if [[ $last_date  == "--" ]] || [[ $last -lt $ok ]]; then
	new_dir="$dir/Backup-$now_date"
	mkdir $new_dir
	cp $source/* $new_dir
	echo "Backup $now_date added"
	ls $new_dir | awk '{print " |+| "$0}'
else
	cur_dir="$dir/Backup-$last_date"
	echo "Backup $last_date updated ($now_date)"
	for file in `ls $source`; do
		if [[ ! -f $cur_dir/$file ]]; then
      			cp $source/$file $cur_dir/$file
      			echo " |+| $file"
    		fi
  	done
	for file in `ls $source`; do
    		if ! cmp -s "$cur_dir/$file" "$source/$file"; then
			if [[ ! -f $cur_dir/$file.$now_date ]] || ! cmp -s "$source/$file" "$cur_dir/$file.$now_date"; then
      				cp $source/$file $cur_dir/$file.$now_date
      				echo " |change| $file $file.$now_date"
			fi
    		fi
  	done
fi >> $report
