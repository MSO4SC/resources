#!/bin/bash -l

ZA_SLURM="${4}/${6}"

cat > $ZA_SLURM <<- EOM
#!/bin/bash -l

#SBATCH -p cola-corta #thin-shared
#SBATCH -N 1
#SBATCH --ntasks-per-node=1
#SBATCH -t 00:20:00

cd $4

mpirun singularity exec -B /mnt:/mnt,/scratch:/scratch $7 /bin/bash $8 $1 $2 $3 $4 $5 


# $1: za_lig
# $2: za_tar
# $3: za_charge
# $4: za_simpath
# $5: za_mail
# $6: za_post_slurm -> prep slurm script (here as here doc)
# $7: za_image
# $8: za_post_script -> za_prep_md.sh (in container)

EOM
