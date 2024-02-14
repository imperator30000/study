#!/bin/bash

mkdir -p my_python_env
cd my_python_env

python3.9 -m venv env
source env/bin/activate
pip install psutil
pip install matplotlib
