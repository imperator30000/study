#!/bin/bash

ans=1
mode="+"

function finish() {
  killall tail
  kill $(cat .pid)
  exit $1
}

# Обработка данных из pipe
(tail -f pipe) | while true
do
  read line
  case $line in
    "+")
      mode="+"
      ;;
    "*")
      mode="*"
      ;;
    QUIT)
      echo "answer $ans"
      finish 0
      ;;
    *)
      if [[ $line =~ ^-?[0-9]+$ ]]
      then
        if [[ $mode == "+" ]]
        then
          let ans=$ans+$line
        else
          let ans=$ans*$line
        fi
      else
        echo "unknown mode $line"
        finish 1 
      fi
      ;;
  esac
done
