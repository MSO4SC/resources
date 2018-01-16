#!/bin/bash

export COPYFILE_DISABLE=true
cd $1 || exit 1
tar --exclude=deploy.sh --exclude=README.adoc -czf ../$1.tar.gz upload || exit 1
cd ..
