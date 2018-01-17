#!/bin/bash

usage(){
   echo ""
   echo "Description:"
   echo "               Package an application for MSO portal deployement"
   echo ""
   echo "Usage:"
   echo ""
   echo ""
   echo "-h             Prints this help information"
   echo ""
   exit 1
}

DEBUG=0

#########################################################
## parse parameters
##########################################################
while getopts "hd:o:" option ; do
   case $option in
       h ) usage ;;
       f ) DIRECTORY=$OPTARG ;;
       o ) OUTPUT==$OPTARG ;;
       d ) DEBUG=1 ;;
       ? ) usage ;;
   esac
done
# shift to have the good number of other args
shift $((OPTIND - 1))

: ${DIRECTORY:="hifimagnet_test"}
: ${OUTPUT:=$DIRECTORY}

export COPYFILE_DISABLE=true

cd $DIRECTORY || exit 1
tar --exclude=deploy.sh --exclude=README.adoc -czf ../$OUTPUT.tar.gz upload || exit 1
cd ..
