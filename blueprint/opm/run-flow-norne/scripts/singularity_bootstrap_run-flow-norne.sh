#!/bin/bash -l

WORKDIR=$1

cd $WORKDIR

# Only way to get a sparse clone from github is to use subversion
svn export https://github.com/OPM/opm-data/trunk/norne/INCLUDE
svn export https://github.com/OPM/opm-data/trunk/norne/NORNE_ATW2013.DATA
