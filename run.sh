#!/bin/bash
chuck --bufsize64 main.ck &
python ./main.py
pkill -SIGINT chuck

