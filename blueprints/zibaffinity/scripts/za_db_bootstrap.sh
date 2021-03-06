#!/bin/bash -l


if [ ! -f $2/$3 ]; then

    module purge
    module load $4
    
    cd $2
    singularity pull --name $3 $1

    #cp $1/$3 $2/
    #cp $SINGULARITY_REPO/$3 $2/
    
    module unload $4
fi

### the actual reason why i couldn't mae use of "hpc.node.singularity_job" type:
za_tar=$(echo ${7} | sed 's#http://##g')


### download default ligand file for testing
#curl -O $1 ${10}
wget -O ${11} ${10}

ZA_SLURM="${2}/${6}"

cat > $ZA_SLURM <<- EOM
#!/bin/bash -l

#SBATCH -p $9 #thin-shared
#SBATCH -N 1
#SBATCH --ntasks-per-node 1
#SBATCH -t 00:00:59
#SBATCH --mail-user=${13}
#SBATCH --mail-type=BEGIN
###SBATCH --reservation=MSO4SC

cd $2

singularity exec -H \$HOME:/home/\$USER -B /mnt:/mnt,/scratch:/scratch $3 /bin/bash $5 $za_tar $8 $2


# $1 { get_input: za_image_path }
# $2 { get_input: za_work_path }
# $3 { get_input: za_image }
# $4 { get_input: za_module_sing }
# $5 { get_input: za_db_script }
# $6 { get_input: za_db_slurm }
# $7 { get_input: mso4sc_dataset_tar }
# $8 { get_input: za_db }
# $9 { get_input: za_hpc_cluster }
# ${10} { get_input: ligand URL }
# ${11} { get_input: ligand name }
# ${12} { get_input: za_mail }
# ${13} *za_user_mail
# ${14} *za_outfile

EOM

