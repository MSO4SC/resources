#!/bin/bash -l

URI=$1
FILENAME=$2

rm -f $FILENAME &> revert.log
