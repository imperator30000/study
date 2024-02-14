#!/bin/bash

HOME=/home/user
trash=$HOME/.trash
logs=$HOME/.trash.log
tmplogs=$HOME/.trash_tmp.log

if [[ -f "$tmplogs" ]]; then
	rm -f "$tmplogs"
fi
touch "$tmplogs"

if [[ $# -ne 1 ]]; then
	echo "Illegal count of arguments: expected 1, but found $#"
	exit 1
fi
save() {
	target_dir=$1
	link_name=$2
	source_file=$3
	echo $target_dir" "$link_name" "$source_file
	ln "$source_file" "$target_dir/$link_name"
    	echo "Link created at $target_dir/$link_name"
}

name=$1
while read -r line; do
	path=$(echo $line | cut -d ' ' -f 1)
	deleted_name=$(echo $line | cut -d ' ' -f 2)
	ans=""
	if [[ "$(basename $path)" != "$name" ]]; then
		echo "$line" >> $tmplogs
		continue
	fi
	current_name=$name
	while [[ $ans != y ]] && [[ $ans != n ]]; do
		echo "Do you want to recover $path (deleted_name: $deleted_name)? (y/n)"
		read ans<&1
	done
	if [[ $ans == n ]]; then
		echo "$line" >> $tmplogs
		continue
	fi
	dirpath=$(dirname "$path")
	if [ ! -d "$dirpath" ]; then
		echo "Not found $dirpath. $name will be saved in the home directory"
		dirpath="$HOME"
	fi
	echo $name
	while [[ -f $dirpath/$current_name ]] || [[ -z $current_name ]]; do
		echo "A duplicate was found. Enter a new file name"
		read current_name<&1
       	done
	echo $dirpath" "$current_name" "$trash/$deleted_name
	ls $trash
	save $dirpath $current_name "$trash/$deleted_name"
	rm -f $trash/$deleted_name
	echo "ok"

done <<< $(cat $logs)
rm -f "$logs"
mv "$tmplogs" "$logs"
