#!/bin/bash

cur_dir=$(pwd)
home_dir=$HOME

GREEN='\033[0;32m'
RESET='\033[0m'
RED='\033[0;31m'
if [ "$cur_dir" == "$home_dir" ];then
	echo -e "${GREEN}Home directory:${RESET} $home_dir"
	exit 0
else
	echo -e "${RED}The script was not launched from the home directory${RESET}"
	exit 1
fi
