#!/bin/bash -l

module load singularity/2.4.2
module load git

echo $1 > bootstrap_log
echo $2 >> bootstrap_log
echo $3 >> bootstrap_log
echo $4 >> bootstrap_log
echo $5 >> bootstrap_log
echo $6 >> bootstrap_log
echo $7 >> bootstrap_log

REMOTE_URL=$1
IMAGE_URI=$2
IMAGE_NAME=$3

# cd $CURRENT_WORKDIR ## not needed, already started there
singularity pull --name $IMAGE_NAME $IMAGE_URI

git clone https://bitbucket.org/fenics-hpc/unicorn.git

cd unicorn
git fetch --all
git checkout next

cd wing_sim01
if [ ${REMOTE_URL} != "NONE" ]
then
	wget $REMOTE_URL
	ARCHIVE=$(basename $REMOTE_URL)
	tar zxvf $ARCHIVE
else
cp mesh0.bin mesh.bin
fi


echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > parameters.xml
echo -e "" >> parameters.xml
echo -e "<dolfin xmlns:dolfin=\"http://fenicsproject.org\">" >> parameters.xml
echo -e "  <parameters name=\"parameters\">" >> parameters.xml 
echo -e "    <parameter name=\"T\" type=\"real\" value=\"$4\"/>" >> parameters.xml
echo -e "    <parameter name=\"alpha\" type=\"real\" value=\"$5\"/>" >> parameters.xml
echo -e "    <parameter name=\"cfl_target\" type=\"real\" value=\"$6\"/>" >> parameters.xml
echo -e "    <parameter name=\"trip_factor\" type=\"real\" value=\"$7\"/>" >> parameters.xml
echo -e "  </parameters>" >> parameters.xml
echo -e "</dolfin>" >> parameters.xml



cd ../..


