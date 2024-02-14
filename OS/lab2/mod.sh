#!/bin/bash

ps aeo pid=,vsz= | sort -k 2,2n | tail -n -1 | awk '{print $1 ":" $2}'
