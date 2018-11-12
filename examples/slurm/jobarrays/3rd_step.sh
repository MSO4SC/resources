#!/bin/sh

module purge
module load gcc openmpi

mpirun echo "3rd_step.sh: hello from host $(hostname), job $SLURM_ARRAY_JOB_ID, array index $SLURM_ARRAY_TASK_ID"
