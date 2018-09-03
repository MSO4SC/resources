#!/bin/bash -l

ZA_SLURM="${4}/${6}"

za_tar=$(echo ${2} | sed 's#http://##g')
MAIL_ATTACH_PATH=${1%.*}


cat > $ZA_SLURM <<- EOM
#!/bin/bash -l

#SBATCH -p $9 # thin-shared  # thinnodes 
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH -t 00:20:00
#SBATCH --mail-user=${12}
#SBATCH --mail-type=END
###SBATCH --reservation=MSO4SC

cd $4

singularity exec -H \$HOME:/home/\$USER -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $za_tar $3 $4 $5 ${10} ${11} ${12}

MAIL_MSG='Dear guy,\n\nPlease find attached the result of the binding affinity calculations. The tar.gz archive contains two files:\n\nFile 1) Atomistic resolution of the optimal binding mode of the protein-ligand complex including explicit water.\n\nFile 2) A text file containing the free binding energy and its thermodynamic contributions along with corresponding weights.\n\nBye bye!'

TEMPFILE=\$(mktemp)
echo -e \$MAIL_MSG > \$TEMPFILE

cat \$TEMPFILE | mailx -s "ZIBaffinity result files" -a ${MAIL_ATTACH_PATH}/${11}.tar.gz ${12}

sleep 20



# $1: za_lig
# $2: mso4sc_dataset_tar
# $3: za_charge
# $4: za_simpath
# $5: za_mail
# $6: za_post_slurm -> prep slurm script (here as here doc)
# $7: za_image
# $8: za_post_script -> za_post_sim.sh (in container)
# $9: za_hpc_cluster -> thin-shared
# ${10}: za_gmx_path
# ${11}: za_outfile
# ${12}: za_user_mail

EOM

