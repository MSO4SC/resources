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
ADAPT_ITER=$(($7))


FILE="touch.script"

cat > $FILE <<- EOM
#!/bin/bash -l

#SBATCH -p $9
#SBATCH -N $NO_NODES
#SBATCH -n $NO_CORES
#SBATCH --ntasks-per-node=$NO_CPN
#SBATCH -t $TIME

module add gcc/5.3.0
module add openmpi/1.10.2
module add singularity/2.4.2

counter=0
while [ \$counter -le $ADAPT_ITER ]
do
	mkdir adapt_\$counter
	mpirun -n $NO_CORES singularity exec -B \$PWD/unicorn:/home -B /mnt  -B /scratch --pwd /home/wing_sim01 $IMAGE_NAME ./wing > log1_\$counter 2>log2_\$counter
	mpirun -n 1 singularity exec -B \$PWD/unicorn:/home -B /mnt  -B /scratch --pwd /home/wing_sim01 $IMAGE_NAME /usr/local/bin/dolfin_post -m mesh_out.bin -t vtk -n 200 -s velocity

	mv ./unicorn/wing_sim01/*bin adapt_\$counter
	mv ./unicorn/wing_sim01/*vtu adapt_\$counter
	mv ./unicorn/wing_sim01/*pvd adapt_\$counter

	cp adapt_\$counter/rmesh.bin ./unicorn/wing_sim01/mesh.bin
	((counter++))
done
EOM

