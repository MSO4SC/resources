#!/bin/bash

echo "Getting Traffic data"
    mkdir -p $1/$USER/simulation/traffic
    wget $2 -P $1/$USER/simulation/traffic
echo "OK!"
