#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_megahit_checkm2
#BSUB -o ./launch_megahit_checkm2.%J.out
#BSUB -e ./launch_megahit_checkm2.%J.err

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
# 12 CheckM2
create_dir $CHECKM_DIR2
init_dir $CHECKM2_MEGA $CHECKM2_LOGS_O_MEGA $CHECKM2_LOGS_E_MEGA
# --- End Create File Structure ---

# --- Launch Job ---
# Job 12A: CheckM2 (depends on 9A1, runs concurrently with 9B/9C) MEGAHIT
echo "Launching Job 12A: CheckM2"
JOBID12A=$(bsub -J "$JOB12A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB12A_CPUS \
    -q $JOB12A_QUEUE \
    -R "rusage[mem=$JOB12A_MEMORY]" \
    -M $JOB12A_MEMORY \
    -W $JOB12A_TIME \
    -o "${CHECKM_LOGS_O_MEGA}/megahit_checkm.12A.%J_%I.log" \
    -e "${CHECKM_LOGS_E_MEGA}/megahit_checkm.12A.%J_%I.err" \
    < ./${JOB12A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 12A array with ID $JOBID12A"