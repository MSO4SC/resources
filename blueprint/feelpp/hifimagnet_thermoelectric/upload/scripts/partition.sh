#! /bin/bash

INPUT=$1
OUTPUT=${INPUT}
PARTS=${2:1}
FORCE=${3:false}

if [ -z $INPUT ]; then
    echo "no input params found"
    echo "usage: partition INPUT [PARTS] [false|true]"
    exit 1
fi

if [ $PARTS -eq 1 ]; then
    echo "skip partition as PARTS=$PARTS"
    exit 0
fi

# check if $OUTPUT.json is already partitioned with PARTS
if [ -f ${OUTPUT}.json ]; then
    N=$(egrep "\"n\":" ${OUTPUT}.json |  cut -d ":" -f2 | tr -d '[:space:]' | tr -d '\"')
    if [ $N -eq $PARTS ] && [ ! $FORCE ]; then
	echo "${OUTPUT}.json already partitionned with $PARTS"
        exit 0
    fi
fi

if [ -f ${INPUT}.geo ]; then
    echo "input is a geofile ${INPUT}.geo"
    exit 0
fi

MSH=""
if [ -f ${INPUT}.msh ]; then
    MSH=${INPUT}.msh
elif [ -f ${INPUT}.med ]; then
    MSH=${INPUT}.med
fi

feelpp_mesh_partitioner --gmsh.scale=0.001 --ifile ${MSH} --ofile ${OUTPUT} --part ${PARTS} > partition.log 2>&1
status=$?

if [ "$status" != "0" ]; then
    echo "feelpp_mesh_partitioner --gmsh.scale=0.001 --ifile ${MSH} --ofile ${OUTPUT} --part ${PARTS}: FAILS (status=$status)"
    echo "see partition.log for details"
    exit 1
fi
