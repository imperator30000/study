#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RESET='\033[0m'
while true; do
	echo "____________________"
	echo -e "| ${YELLOW}Меню:${RESET}            |"
	echo -e "| ${YELLOW}1)${RESET} ${GREEN}Редактор nano${RESET} |"
	echo -e "| ${YELLOW}2)${RESET} ${GREEN}Редактор vi${RESET}   |"
	echo -e "| ${YELLOW}3)${RESET} ${GREEN}Браузер links${RESET} |"
	echo -e "| ${YELLOW}4)${RESET} ${GREEN}Выход${RESET}         |"
	echo "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯"
	read -r input
	if [ "$input" == "1" ];then
		nano
	elif [ "$input" == "2" ]; then
		vi
	elif [ "$input" == "3" ]; then
		links
	elif [ "$input" == "4" ]; then
		echo -e "${RED}Выход.${RESET}"
		exit 0
	else
		echo -e "${RED}Некорректный ввод. Повторите ввод.${RESET}"
	fi
done
