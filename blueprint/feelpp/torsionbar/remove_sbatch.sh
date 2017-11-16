#!/bin/bash -l

FILE=$2

if [ -f $FILE ]; then
    rm $FILE
fi
