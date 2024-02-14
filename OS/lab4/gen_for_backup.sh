#!/bin/bash

cd ..
mkdir source

mkdir Backup-2021-11-03
mkdir Backup-2022-11-09
mkdir Backup-2023-11-10
cd source
for (( i=1; i<=10; i++ ))
do
  for (( j=1; j<=3; j++ ))
    do
      touch "$i.$j"
    done
done



