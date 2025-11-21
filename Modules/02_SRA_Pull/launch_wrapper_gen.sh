#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_wrapper_gen
#BSUB -o ./launch_wrapper_gen.%J.out
#BSUB -e ./launch_wrapper_gen.%J.err

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
# Job 1: Generate LSF Wrappers
echo "Launching Job 1: LSF Wrapper Generation"
JOBID1=$(bsub -J "$JOB1[1-$NUM_JOB]%$NUM_JOB" \
     -n $JOB1_CPUS \
     -q $JOB1_QUEUE \
     -R "rusage[mem=$JOB1_MEMORY]" \
     -o "${WRAP_LOGS_O}/wrapper.gen.%J.%I.log" \
     -e "${WRAP_LOGS_E}/wrapper.gen.%J.%I.err" \
     -W $JOB1_TIME \
     < ${RUN_SCRIPTS}/${JOB1}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 1 array with ID $JOBID1"