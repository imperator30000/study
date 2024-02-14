#!/bin/bash

awk '{print $NF}' $1 | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}'

