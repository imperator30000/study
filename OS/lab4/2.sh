#!/bin/bash

mkdir test
cd test
touch 1111.py
touch 12.sh
touch 13.sh
touch 14.sh
touch 15.sh
touch 16.sh
touch 17.sh
touch 18.sh
touch 19.sh
touch 20.sh
touch 21.sh

/home/user/lab4/rmtrash.sh 1111.py
/home/user/lab4/rmtrash.sh 12.sh
/home/user/lab4/rmtrash.sh 13.sh
/home/user/lab4/rmtrash.sh 14.sh
/home/user/lab4/rmtrash.sh 15.sh
/home/user/lab4/rmtrash.sh 16.sh
/home/user/lab4/rmtrash.sh 17.sh
/home/user/lab4/rmtrash.sh 18.sh
/home/user/lab4/rmtrash.sh 19.sh
/home/user/lab4/rmtrash.sh 20.sh
/home/user/lab4/rmtrash.sh 21.sh

cd ..
rm -rf test
