#!/bin/bash -l

FILE="${4}/${6}"

if [ -f $FILE ]; then
    rm $FILE
fi
