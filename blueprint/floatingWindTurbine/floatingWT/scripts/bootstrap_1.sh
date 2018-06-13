#!/bin/bash -l

module load singularity/2.4.2

SINGULARITY_PULLFOLDER=$1
singularity pull shub://sregistry.srv.cesga.es/mso4sc/fenics-unicorn:latest

git clone https://bitbucket.org/fenics-hpc/unicorn.git
cd unicorn
git fetch --all
git checkout unicorn_var_den_ale

echo $2 > meshaddress

echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > parameters.xml
echo -e "" >> parameters.xml
echo -e "<dolfin xmlns:dolfin=\"http://fenicsproject.org\">" >> parameters.xml
echo -e "  <parameters name=\"parameters\">" >> parameters.xml 
echo -e "    <parameter name=\"T\" type=\"real\" value=\"$3\"/>" >> parameters.xml
echo -e "    <parameter name=\"no_samples\" type=\"int\" value=\"$4\"/>" >> parameters.xml
echo -e "    <parameter name=\"air_density\" type=\"real\" value=\"$5\"/>" >> parameters.xml
echo -e "    <parameter name=\"fluid_density\" type=\"real\" value=\"$6\"/>" >> parameters.xml
echo -e "    <parameter name=\"platform_density\" type=\"real\" value=\"$7\"/>" >> parameters.xml
echo -e "    <parameter name=\"platform_volume\" type=\"real\" value=\"$8\"/>" >> parameters.xml
echo -e "    <parameter name=\"dynamic_viscosity\" type=\"real\" value=\"$9\"/>" >> parameters.xml
echo -e "  </parameters>" >> parameters.xml
echo -e \"</dolfin>\" >> parameters.xml


