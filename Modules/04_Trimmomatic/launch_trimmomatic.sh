#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_trimmomatic
#BSUB -o ./launch_trimmomatic.%J.out
#BSUB -e ./launch_trimmomatic.%J.err

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
# 01 In/Out for Wrapper Generation
create_dir $WRAP_OUT $WRAP_SCRIPTS $WRAP_LOGS_O $WRAP_LOGS_E
# --- End Create File Structure ---

# --- Launch Job ---
# Job 4: Trimmomatic
echo "Launching Job 4: Trimmomatic"
JOBID4=$(bsub -J "$JOB4[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB4_CPUS \
    -q $JOB4_QUEUE \
    -R "rusage[mem=$JOB4_MEMORY]" \
    -M $JOB4_MEMORY \
    -W $JOB4_TIME \
    -o "${TRIM_LOGS_O}/trim.04.%J_%I.log" \
    -e "${TRIM_LOGS_E}/trim.04.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB4}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 4 array with ID $JOBID4"