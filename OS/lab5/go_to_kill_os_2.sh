#!/bin/bash
./start_info.sh
./get_mem_swap_info_2.sh &
./mem.bash &
pid1=$!
./mem2.bash &
pid2=$!

wait $pid1
wait $pid2

python3 graphic.py
dmesg | grep "mem[2]*.bash" 
echo "report.log: "
cat "report.log"

echo "report2.log: "
cat "report2.log"
