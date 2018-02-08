#!/bin/bash

echo "Getting Mesh"

mkdir -p $1/$USER/simulation/mesh
wget $2 -P $1/$USER/simulation/mesh

echo "OK!"
