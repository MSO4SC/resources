#!/bin/bash -l

ZA_SLURM="${4}/${6}"

cat > $ZA_SLURM <<- EOM
#!/bin/bash -l

#SBATCH -p cola-corta #thin-shared
#SBATCH -N 1
#SBATCH -n 24
####SBATCH --ntasks-per-node=1
#SBATCH -t 00:13:00

echo OMP_NUM_THREADS: \\$OMP_NUM_THREADS
declare +x OMP_NUM_THREADS

cd $4

mpirun -np 24 singularity exec -B /mnt:/mnt,/scratch:/scratch $7 $9 $1 $2 $3 $4 $5 \\$SLURM_ARRAY_TASK_ID $8
#mpirun -np 24 singularity exec ...


# $1: za_lig
# $2: za_tar
# $3: za_charge
# $4: za_simpath
# $5: za_mail
# $6: za_slurm_script -> slurm script (here as here doc)
# $7: za_image
# $8: za_ntomp
# $9: za_main_script -> za_main.sh (in container)

EOM
