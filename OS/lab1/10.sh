#!/bin/bash

man bash | grep -oE '\b\w{4,}\b' | awk '{print tolower($0)}' | sort | uniq -c | sort -nr | head -n 3 |  awk '{print $2,$1}'

