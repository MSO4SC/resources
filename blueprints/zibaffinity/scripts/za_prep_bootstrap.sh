#!/bin/bash -l

ZA_SLURM="${4}/${6}"

za_tar=$(echo ${2} | sed 's#http://##g')


cat > $ZA_SLURM <<- EOM
#!/bin/bash -l

#SBATCH -p $9 #thin-shared
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH -t 00:15:00
##SBATCH --mail-user=$5
##SBATCH --mail-type=ALL
###SBATCH --reservation=MSO4SC

cd $4

singularity exec -H \$HOME:/home/\$USER -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $za_tar $3 $4 $5 ${10}

# $1: za_lig
# $2: mso4sc_dataset_tar
# $3: za_charge
# $4: za_work_path
# $5: za_mail
# $6: za_prep_slurm -> prep slurm script (here as here doc)
# $7: za_image
# $8: za_prep_script -> za_prep_sim.sh (in container)
# $9: za_hpc_cluster -> thin-shared
# ${10}: za_gmx_path

EOM

