#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_megahit_quast
#BSUB -o ./launch_megahit_quast.%J.out
#BSUB -e ./launch_megahit_quast.%J.err

# --- Housekeeping ---
# load config
source ./config.sh
# Working Dir -- should be made already but just in case...
create_dir $WORKING_DIR $RUN_SCRIPTS
# get sample list & export number of samples
if [[ ! -f ${XFILE} ]]; then
    echo "Sample list file ${XFILE} not found!"
    exit 1
fi
# get number of jobs
export NUM_JOB=$(wc -l < "${XFILE}")

# --- Create File Structure ---
# 11 QUAST
create_dir $QUAST_DIR
init_dir $QUAST_MEGA $QUAST_LOGS_O_MEGA $QUAST_LOGS_E_MEGA # MEGAHIT
# --- End Create File Structure ---

# --- Launch Job ---
# Job 11A: QUAST (depends on 9A) - MEGAHIT
echo "Launching Job 11A: QUAST"
JOBID11A=$(bsub -J "$JOB11A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB11A_CPUS \
    -q $JOB11A_QUEUE \
    -R "rusage[mem=$JOB11A_MEMORY]" \
    -M $JOB11A_MEMORY \
    -W $JOB11A_TIME \
    -o "${QUAST_LOGS_O_MEGA}/megahit_quast.11A.%J_%I.log" \
    -e "${QUAST_LOGS_E_MEGA}/megahit_quast.11A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB11A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 11A array with ID $JOBID11A"