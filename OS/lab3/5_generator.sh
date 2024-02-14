#!/bin/bash

echo $$ > .pid

while true
do
  read line
  echo "$line" > pipe
done
