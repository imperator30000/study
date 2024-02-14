#!/bin/bash



for (( i=1; i<=10; i++ ))
do
  for (( j=1; j<=3; j++ ))
    do
      touch $i
      ./rmtrash.sh $i
    done
done
