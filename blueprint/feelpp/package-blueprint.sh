#!/bin/bash 

usage(){
   echo ""
   echo "Description:"
   echo " Package an application for MSO portal deployement"
   echo ""
   echo "Usage:"
   echo ""
   echo "-f define directory where the package is stored"
   echo "-n name of the package (default is upload)"
   echo "-o specify the output directory name (if different from input)"
   echo "-h Prints this help information"
   echo ""
   exit 1
}

DEBUG=0

#########################################################
## parse parameters
##########################################################
while getopts "hdf:o:n:" option ; do
   case $option in
       h ) usage ;;
       f ) DIRECTORY=$OPTARG ;;
       n ) PACKAGE=$OPTARG ;;
       o ) OUTPUT=$OPTARG ;;
       d ) DEBUG=1 ;;
       ? ) usage ;;
   esac
done
# shift to have the good number of other args
shift $((OPTIND - 1))

: ${DIRECTORY:="hifimagnet_test"}
: ${PACKAGE:="upload"}
: ${OUTPUT:=$DIRECTORY}

export COPYFILE_DISABLE=true

startupdir=$(echo $PWD)

if [ "$DEBUG" = "1" ]; then
    set -x
fi

if [ ! -d $DIRECTORY ]; then
    echo "no such directory: $DIRECTORY"
    exit 1
fi
cd $DIRECTORY

if [ ! -d $PACKAGE ]; then
    echo "no such package: $PACKAGE"
    exit 1
fi

echo -n "Package $PACKAGE into ../$OUTPUT.tar.gz"
tar --exclude=deploy.sh --exclude=README.adoc -czf ../$OUTPUT.tar.gz $PACKAGE
isOK=$?
cd $startupdir

if [ $isOK = "0" ]; then
    echo "\t OK"
else
    echo "\t FAILED"
    exit
fi


if [ "$DEBUG" = "1" ]; then
    set +x
fi

