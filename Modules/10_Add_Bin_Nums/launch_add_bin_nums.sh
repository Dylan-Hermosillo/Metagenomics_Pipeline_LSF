#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_add_bin_nums
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
# 10 Add Bin Numbers
create_dir $ADD_BIN_DIR $ADD_BIN_LOGS_O $ADD_BIN_LOGS_E
# --- End Create File Structure ---

# --- Launch Job ---
# Job 10: Add Bin Numbers (depends on 9A & 9B)
echo "Launching Job 10: Add Bin Numbers"
JOBID10=$(bsub -J "$JOB10[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB10_CPUS \
    -q $JOB10_QUEUE \
    -R "rusage[mem=$JOB10_MEMORY]" \
    -M $JOB10_MEMORY \
    -W $JOB10_TIME \
    -o "${ADD_BIN_LOGS_O}/add_bin_nums.10.%J_%I.log" \
    -e "${ADD_BIN_LOGS_E}/add_bin_nums.10.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB10}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 10 array with ID $JOBID10"