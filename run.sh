#!/bin/bash
chuck --bufsize64 chuck.ck &
python ./osctest.py
pkill -SIGINT chuck

