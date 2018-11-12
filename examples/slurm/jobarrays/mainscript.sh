#!/bin/bash

###############################
# Workflow:
#
# Step1 -> Ok -> Step2 -> Ok -> Step3 -> Ok -> Step 4
#   |              |              |              |
# Fail           Fail           Fail           Fail
#   |              |              |              |
# Stop           Stop           Stop           Stop
#
# Next step is launched secuentilly if the previous
# has been succesfully executed (exit code = 0)
#
# Each step is a jobarray.
#
# To identify which component of the job array
# is being currently executed, we can use 
# $SLURM_ARRAY_TASK_ID environment variable.
###############################

###############################
# SCALAR VARIABLES
###############################

PARTITION="cola-corta"
DEPENDENCY=""
NUMBER_STEPS=4

###############################
# ARRAY VARIABLES
# The size of the arrays must be equal to $NUMBER_STEPS
# This arrays are iterated in order to represent the execution workflow.
###############################
 
SCRIPT_PER_STEP=( 1st_step.sh 2nd_step.sh 3rd_step.sh 4th_step.sh ) # Name of the scripts per step
ARRAY_SIZE_PER_STEP=( 1 6 6 1 )                                     # Number of executions per step
CORES_PER_EXECUTION=( 1 4 4 1 )                                     # Number of cores/execution per step
TIME_PER_EXECUTION=( 00:01:00 00:02:00 00:03:00 00:01:00 )          # Time limit per step

# VALUES USED FOR ZIBAFFINITY WORKFLOW
# ARRAY_SIZE_PER_STEP=( 1 61 61 1 )
# CORES_PER_EXECUTION=( 1 24 6 1 )
# TIME_PER_EXECUTION=( 00:05:00 02:00:00 00:10:00 00:15:00 )


for i in `seq 0 $(($NUMBER_STEPS-1))`; do
    ###############################
    # Build sbatch command
    ###############################
    JOB_CMD="sbatch "
    JOB_CMD="$JOB_CMD -p $PARTITION"                               # Slurm partition
    JOB_CMD="$JOB_CMD -n ${CORES_PER_EXECUTION[$i]}"               # Number of cores (per array component)
    JOB_CMD="$JOB_CMD -N 1"                                        # Number of nodes (per array component)
    JOB_CMD="$JOB_CMD -t ${TIME_PER_EXECUTION[$i]}"                # Execution time  (per array component)
    JOB_CMD="$JOB_CMD --array=0-$((${ARRAY_SIZE_PER_STEP[$i]}-1))" # Job array range (0-NumberOfComponents)
                                                                   # $SLURM_ARRAY_TASK_ID environment
    if [ -n "$DEPENDENCY" ] ; then
       JOB_CMD="$JOB_CMD --dependency afterok:$DEPENDENCY"         # Job chain (specify dependency with previous job)
    fi
    JOB_CMD="$JOB_CMD ${SCRIPT_PER_STEP[$i]}"
    echo "$i. Running command: $JOB_CMD  "

    ###############################
    # Launch $JOB_CMD
    ###############################
    OUT=`$JOB_CMD`
    echo "$i. Output: $OUT"
    DEPENDENCY=`echo $OUT | awk '{print $4}'`                      # Get the JobID to use it as dependency in next iteration
done

