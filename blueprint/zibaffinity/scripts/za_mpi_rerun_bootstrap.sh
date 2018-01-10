#!/bin/bash -l

ZA_SLURM="${4}/${6}"

cat > $ZA_SLURM <<- EOM
#!/bin/bash -l

#SBATCH -p cola-corta #thin-shared
#SBATCH -N 1
#SBATCH -n $9
#SBATCH -t 00:15:00

#declare +x OMP_NUM_THREADS

cd $4

mpirun -np $9 singularity exec -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $2 $3 $4 $5 ${10} $9
#mpirun -np $9 singularity exec -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $2 $3 $4 $5 \\$SLURM_ARRAY_TASK_ID $9


# $1: za_lig
# $2: za_tar
# $3: za_charge
# $4: za_simpath
# $5: za_mail
# $6: za_mpi_em_slurm -> slurm script (here as here doc)
# $7: za_image
# $8: za_mpi_rerun_script -> za_mpi_rerun.sh (in container)
# $9: za_ntrerun  -> not really required in child scripts
# 

EOM
