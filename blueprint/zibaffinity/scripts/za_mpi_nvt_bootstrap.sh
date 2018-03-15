#!/bin/bash -l

ZA_SLURM="${4}/${6}"

za_tar=$(echo ${2} | sed 's#http://##g')

cat > $ZA_SLURM <<- EOM
#!/bin/bash -l

#SBATCH -p $9 #thin-shared
#SBATCH -N 1
#SBATCH -n ${10}
#SBATCH -t 00:20:00

#declare +x OMP_NUM_THREADS

cd $4

mpirun -np ${10} singularity exec -H \$HOME:/home/\$USER -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $za_tar $3 $4 $5 ${11} ${10}
#mpirun -np ${10} singularity exec -H \$HOME:/home/\$USER -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $za_tar $3 $4 $5 \$SCALE_INDEX ${10}
#mpirun -np ${10} singularity exec -H \$HOME:/home/\$USER -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $za_tar $3 $4 $5 \$SLURM_ARRAY_TASK_ID ${10}


# $1: za_lig
# $2: za_tar
# $3: za_charge
# $4: za_simpath
# $5: za_mail
# $6: za_mpi_em_slurm -> slurm script (here as here doc)
# $7: za_image
# $8: za_mpi_nvt_script -> za_mpi_nvt.sh (in container)
# $9: za_hpc_cluster -> cola-corta
# $10: za_nt  -> not really required in child scripts
# $11: za_slurm_idx  -> manual slurm array index

EOM
