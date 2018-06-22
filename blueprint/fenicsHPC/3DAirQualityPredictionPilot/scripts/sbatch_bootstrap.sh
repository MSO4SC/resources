#!/bin/bash -l

#module load singularity/2.4.2
#module load git

echo "bootstrap_batch ...." >> bootstrap_log
echo $1 >> bootstrap_log
echo $2 >> bootstrap_log
echo $3 >> bootstrap_log
echo $4 >> bootstrap_log
echo $5 >> bootstrap_log
echo $6 >> bootstrap_log
echo $7 >> bootstrap_log
echo $8 >> bootstrap_log
echo $9 >> bootstrap_log
echo ${10} >> bootstrap_log

REMOTE_URL=${10}
IMAGE_URI=$1
IMAGE_NAME=$2

NO_CORES=$3
NO_NODES=$4
NO_CPN=$5
TIME=$6
#ADAPT_ITER=$(($7))


FILE="touch.script"

cat > $FILE <<- EOM
#!/bin/bash -l

#SBATCH -p $9
#SBATCH -N $NO_NODES
#SBATCH -n $NO_CORES
#SBATCH --ntasks-per-node=$NO_CPN
#SBATCH -t $TIME
#SBATCH --reservation=$8

module add gcc/5.3.0
module add openmpi/1.10.2
module add singularity/2.4.2

mkdir results
mpirun -n $NO_CORES singularity exec -B \$PWD/unicorn:/home -B /mnt  -B /scratch --pwd /home/3DAirQualityPredictionPilot $IMAGE_NAME ./3dAirQualityPredictionPilot > log1 2>log2
mpirun -n 1 singularity exec -B \$PWD/unicorn:/home -B /mnt  -B /scratch --pwd /home/3DAirQualityPredictionPilot $IMAGE_NAME /usr/local/bin/dolfin_post -m mesh_out.bin -t vtk -n 200 -s velocity
mv ./unicorn/3DAirQualityPredictionPilot/*bin results
mv ./unicorn/3DAirQualityPredictionPilot/*vtu results
mv ./unicorn/3DAirQualityPredictionPilot/*pvd results
EOM

