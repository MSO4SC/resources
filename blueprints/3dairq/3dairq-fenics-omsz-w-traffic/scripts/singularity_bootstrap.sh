#!/bin/bash -l

module load singularity
module load git

echo $1 > bootstrap_log
echo $2 >> bootstrap_log
echo $3 >> bootstrap_log
echo $4 >> bootstrap_log
echo $5 >> bootstrap_log
echo $6 >> bootstrap_log
echo $7 >> bootstrap_log
echo $8 >> bootstrap_log
echo $9 >> bootstrap_log
echo ${10} >> bootstrap_log
echo ${11} >> bootstrap_log

REMOTE_URL=${11}
IMAGE_URI=$1
IMAGE_NAME=$2

# cd $CURRENT_WORKDIR ## not needed, already started there
singularity pull --name $IMAGE_NAME $IMAGE_URI

#git clone https://bitbucket.org/fenics-hpc/unicorn.git
#cd unicorn
#git fetch --all
#git checkout mleoni/mso4scPilot
#git clone https://bitbucket.org/fenics-hpc/3dairqualitypredictionpilot.git 3DAirQualityPredictionPilot

wget http://mso.tilb.sze.hu/3dairq/mso4sc/3dairq-bare-latest.simg
wget http://mso.tilb.sze.hu/3dairq/mso4sc/unicorn.tar.gz

wget http://mso.tilb.sze.hu/3dairq/mso4sc/traffic.tar.gz
tar -xvzf traffic.tar.gz
cd traffic
wget http://mso.tilb.sze.hu/3dairq/mso4sc/trafficgen.sh
chmod 777 trafficgen.sh
./trafficgen.sh ${10}
cd ..

tar -xvzf unicorn.tar.gz

cd unicorn

wget http://mso.tilb.sze.hu/3dairq/mso4sc/3dairq-fenics.tar.gz
wget http://mso.tilb.sze.hu/3dairq/mso4sc/traffic.tar.gz
tar -xvzf traffic.tar.gz
tar -xvzf 3dairq-fenics.tar.gz


cd 3DAirQualityPredictionPilot

# setting final time

cat <<EOF > parameters.cfg
meshPrefix = mesh/
inputFilesPrefix = inputFiles/
windFileX = wind.windx
windFileY = wind.windy
segmentsFile = simple_traffic.trnet
emissionFile = simple_traffic.tremi
NOProdPerc = 0.95
NO2ProdPerc = 0.05
boundaryAirPollution = 0
NOInitialConcentration = 0
NO2InitialConcentration = 0
O3InitialConcentration = 0
NOBackground = 0
NO2Background = 0
O3Background = 0
dt = 30
tFinal = $9
noSamples = 1440
EOF

# getting wind files
cd inputFiles
wget $7
wget $8
cd ..

if [ ${REMOTE_URL} != "NONE" ] && [ ${REMOTE_URL}x != "x" ] 
then
	wget $REMOTE_URL
	ARCHIVE=$(basename $REMOTE_URL)
	tar zxvf $ARCHIVE
else
	mkdir mesh
	cd mesh
	wget www.csc.kth.se/~ncde/mso4scMeshes.tar.bz2
	tar -xvjf mso4scMeshes.tar.bz2
	cd ..
fi

echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > parameters.xml
echo -e "" >> parameters.xml
echo -e "<dolfin xmlns:dolfin=\"http://fenicsproject.org\">" >> parameters.xml
echo -e "  <parameters name=\"parameters\">" >> parameters.xml 
echo -e "    <parameter name=\"T\" type=\"real\" value=\"$3\"/>" >> parameters.xml
echo -e "    <parameter name=\"alpha\" type=\"real\" value=\"$4\"/>" >> parameters.xml
echo -e "    <parameter name=\"cfl_target\" type=\"real\" value=\"$5\"/>" >> parameters.xml
echo -e "    <parameter name=\"trip_factor\" type=\"real\" value=\"$6\"/>" >> parameters.xml
echo -e "  </parameters>" >> parameters.xml
echo -e "</dolfin>" >> parameters.xml

cd ../..
cd traffic
LINKER_PATH="/linker/linker.jar"

echo "Generating traffic"
SINGULARITYENV_SUMO_HOME=/sumo singularity exec -B /mnt ../3dairq-bare-latest.simg /sumo/sumo s_gyor.sumocfg > make_out 2>make_err

sumo_param1=`find  -name *net.xml`
sumo_param2=`find  -name gyor_forg_5_min_lane.xml`
echo $sumo_param1
echo $sumo_param2

echo "Generating Emission"
singularity exec -B /mnt ../3dairq-bare-latest.simg java -jar "$LINKER_PATH" -m traffic $sumo_param1,$sumo_param2 simple_traffic sumo_test.ltm > make_out2 2>make_err2
cp *.tremi ../unicorn/3DAirQualityPredictionPilot/inputFiles
cp *.trnet ../unicorn/3DAirQualityPredictionPilot/inputFiles
cd ..



