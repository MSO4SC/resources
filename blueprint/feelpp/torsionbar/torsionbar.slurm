#!/bin/bash
#SBATCH -p thin-shared
#SBATCH -n 4
#SBATCH -t 00:20:00
#SBATCH -o slurm.%j.%N.out
#SBATCH -e slurm.%j.%N.err
#SBATCH -v
#SBATCH --threads-per-core=1
##SBATCH --ntasks-per-node=1
##SBATCH --mail-type=ALL
##SBATCH --mail-user=dolle.guillaume@gmail.com


module load singularity/2.3.2

export FEELPP_MOUNT_DIR=${LUSTRE}/feel/singularity/
export FEELPP_SINGULARITY_IMAGE=${LUSTRE}/singularity_feelpp_feelpp-toolboxes-develop-v0.104.0-alpha.3-ubuntu-16.10.img
export FEELPP_SINGULARITY_RUN="singularity exec -B ${FEELPP_MOUNT_DIR}:/feel ${FEELPP_SINGULARITY_IMAGE}"
export FEELPP_NP=${SLURM_NPROCS}
export FEELPP_GMSH_SCALE=1 # x hsize = new_hsize    (hsize = 0.1 by default)

# PREPROC
${FEELPP_SINGULARITY_RUN} gmsh -3 -clscale ${FEELPP_GMSH_SCALE} -bin \
    -o /feel/torsionbar.msh \
    /opt/feelpp/Testcases/CSM/torsionbar/torsionbar.geo

${FEELPP_SINGULARITY_RUN} feelpp_mesh_partitioner \
    --ifile /feel/torsionbar.msh \
    --odir /feel/mesh_partitioned/ \
    --part ${FEELPP_NP}

# COMPUTE
mpirun --bind-to core ${FEELPP_SINGULARITY_RUN} feelpp_toolbox_solid_3d \
       --config-file /opt/feelpp/Testcases/CSM/torsionbar/torsionbar.cfg \
       --solid.mshfile /feel/mesh_partitioned/torsionbar_p${FEELPP_NP}.json \
       --solid.pc-type gamg \
       --solid.ksp-monitor 1 \
       --ts.restart 0 \
       --solid.scalability-save 1
#       --solve-quasi-static.variable-step=0.001 \

