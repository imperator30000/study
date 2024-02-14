#!/bin/bash
ps axo pid,lstart,cmd | sort -k 5,5 -k 4,4M -k 3,3n -k 2,2 | tail -1

