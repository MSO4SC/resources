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
echo $7 >> bootstrap_log

REMOTE_URL=$1
IMAGE_URI=$2
IMAGE_NAME=$3

NO_CORES=$4
NO_NODES=$5
NO_CPN=$6
TIME=$7
ADAPT_ITER=$8


FILE="touch.script"

cat > $FILE <<- EOM
#!/bin/bash -l

#SBATCH -p cola-corta
#SBATCH -N $NO_NODES
#SBATCH -n $NO_CORES
#SBATCH --ntasks-per-node=$NO_CPN
#SBATCH -t $7

module add gcc/5.3.0
module add openmpi/1.10.2
module add singularity/2.4.2

counter=0
while [ \$counter -le $ADAPT_ITER ]
do
	mkdir adapt_\$counter
	mpirun -n $NO_CORES singularity exec -B \$PWD/unicorn:/home -B /mnt  -B /scratch --pwd /home/wing_sim01 $IMAGE_NAME ./wing > log1 2>log2
	mpirun -n 1 singularity exec -B \$PWD/unicorn:/home -B /mnt  -B /scratch --pwd /home/wing_sim01 $IMAGE_NAME /usr/local/bin/dolfin_post -m mesh_out.bin -t vtk -n 200 -s velocity

	mv *bin adapt_\$counter
	mv *vtu adapt_\$counter
	mv *pvd adapt_\$counter

	cp adapt_\$counter/rmesh.bin mesh.bin
	((counter++))
done
EOM

