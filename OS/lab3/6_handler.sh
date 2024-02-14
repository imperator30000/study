#!/bin/bash

echo $$ > .pid

ans=1

doubleValue() {
  let ans=ans*2
  echo $ans
}

incrementValue() {
  let ans=ans+2
  echo $ans
}

terminateProcess() {
  echo "answer $ans"
  exit
}

decrement() {
  let ans=ans-2
  echo $ans
}

divValue() {
  let ans=ans/2
  echo $ans
}
trap 'incrementValue' USR1
trap 'doubleValue' USR2
trap 'decrement' SIGINT
trap 'divValue' SIGHUP
trap 'terminateProcess' SIGTERM

while true
do
sleep 0
done

