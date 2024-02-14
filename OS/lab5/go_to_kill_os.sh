#!/bin/bash
./start_info.sh
./get_mem_swap_info.sh & 
./mem.bash
python3 graphic.py
dmesg | grep "mem.bash" 
echo "report.log: "
cat "report.log"

