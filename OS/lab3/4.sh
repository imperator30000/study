#!/bin/bash

./process1.sh &
./process2.sh &
./process3.sh &
cpulimit -p $(cat .pid1) -l 10 &
kill $(cat .pid3) &
