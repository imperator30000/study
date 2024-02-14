#!/bin/bash


mkdir test > /dev/null 2>&1 && echo "catalog test was created successfully" >> report && touch test/$(date +%d\\%m\\%Y_%H:%M:%S)
ping -c 1  www.net_nikogo.ru > /dev/null 2>&1 || echo "$(date +%d\\%m\\%Y_%H:%M:%S) host is sleeping" >> report
