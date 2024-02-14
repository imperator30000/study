#!/bin/bash
ps axo pid,command | grep '/sbin/' | awk '{print $1}' > result2.txt

