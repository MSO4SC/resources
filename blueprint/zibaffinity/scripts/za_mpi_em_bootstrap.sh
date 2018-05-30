#!/bin/bash -l

ZA_SLURM="${4}/${6}"

za_tar=$(echo ${2} | sed 's#http://##g')

cat > $ZA_SLURM <<- EOM
#!/bin/bash -l

#SBATCH -p $9 #thin-shared
#SBATCH -N 1
#SBATCH -n ${10}
#SBATCH -t 00:15:00

#declare +x OMP_NUM_THREADS

cd $4

## load dynamic variables \$SCALE_INDEX, \$SCALE_COUNT, \$SCALE_MAX
# DYNAMIC VARIABLES

mpirun -np ${10} singularity exec -H \$HOME:/home/\$USER -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $za_tar $3 $4 $5 \$SCALE_INDEX ${10} ${11}
#mpirun -np ${10} singularity exec -H \$HOME:/home/\$USER -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $za_tar $3 $4 $5 ${11} ${10} ${12}
#mpirun -np ${10} singularity exec -H \$HOME:/home/\$USER -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $za_tar $3 $4 $5 \$SLURM_ARRAY_TASK_ID ${10} ${12}


# $1: za_lig
# $2: za_tar
# $3: za_charge
# $4: za_simpath
# $5: za_mail
# $6: za_mpi_em_slurm -> slurm script (here as here doc)
# $7: za_image
# $8: za_mpi_em_script -> za_mpi_em.sh (in container)
# $9: za_hpc_cluster -> cola-corta
# $10: za_nt  -> not really required in child scripts
# $11: za_gmx_path  -> compiled gromacs 5.1.2

EOM

#                    - { get_input: za_lig }
#                    - { get_input: mso4sc_dataset_tar }
#                    - { get_input: za_charge }
#                    - { get_input: za_work_path }
#                    - { get_input: za_mail }
#                    - { get_input: za_mpi_em_slurm }
#                    - { concat: [ { get_input: za_work_path },'/',{ get_input: za_image } ]}
#                    - { get_input: za_mpi_em_script }
#                    - { get_input: za_hpc_partition }
#                    - { get_input: za_mpi_nt }
