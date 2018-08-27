#!/bin/bash -l

module load singularity/2.4.2
module load git

REMOTE_URL=$1
IMAGE_URI=$2
IMAGE_NAME=$3

# cd $CURRENT_WORKDIR ## not needed, already started there
singularity pull --name $IMAGE_NAME $IMAGE_URI

git clone https://bitbucket.org/fenics-hpc/unicorn.git

cd unicorn
git fetch --all
git checkout unicorn_var_den_ale

wget $REMOTE_URL
ARCHIVE=$(basename $REMOTE_URL)
tar zxvf $ARCHIVE


echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > parameters.xml
echo -e "" >> parameters.xml
echo -e "<dolfin xmlns:dolfin=\"http://fenicsproject.org\">" >> parameters.xml
echo -e "  <parameters name=\"parameters\">" >> parameters.xml 
echo -e "    <parameter name=\"T\" type=\"real\" value=\"$4\"/>" >> parameters.xml
echo -e "    <parameter name=\"no_samples\" type=\"int\" value=\"$5\"/>" >> parameters.xml
echo -e "    <parameter name=\"air_density\" type=\"real\" value=\"$6\"/>" >> parameters.xml
echo -e "    <parameter name=\"fluid_density\" type=\"real\" value=\"$7\"/>" >> parameters.xml
echo -e "    <parameter name=\"platform_density\" type=\"real\" value=\"$8\"/>" >> parameters.xml
echo -e "    <parameter name=\"platform_volume\" type=\"real\" value=\"$9\"/>" >> parameters.xml
echo -e "    <parameter name=\"dynamic_viscosity\" type=\"real\" value=\"${10}\"/>" >> parameters.xml
echo -e "  </parameters>" >> parameters.xml
echo -e "</dolfin>" >> parameters.xml



cd ..

#DIRNAME=$(basename $ARCHIVE .tgz)
#DECK=$(ls $DIRNAME/*.DATA)

#cat << EOF > parameters.xml
#deck_filename=$(readlink -m $CURRENT_WORKDIR)/$DECK
#EOF

