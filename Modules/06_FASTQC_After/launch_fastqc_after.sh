#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_fastqc_after
#BSUB -o ./launch_fastqc_after.%J.out
#BSUB -e ./launch_fastqc_after.%J.err

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
# 06 FastQC After Trim Outputs
init_dir $FASTQC_AFTER $FASTQC_AFTER_LOGS_O $FASTQC_AFTER_LOGS_E $FASTQC_A_HTML
# --- End Create File Structure ---

# --- Launch Job ---
# Job 6: FastQC After Trim
echo "Launching Job 6: FastQC After Trim"
JOBID6=$(bsub -J "$JOB6[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB6_CPUS \
    -q $JOB6_QUEUE \
    -R "rusage[mem=$JOB6_MEMORY]" \
    -M $JOB6_MEMORY \
    -W $JOB6_TIME \
    -o "${FASTQC_AFTER_LOGS_O}/fastqc.06.%J_%I.log" \
    -e "${FASTQC_AFTER_LOGS_E}/fastqc.06.%J_%I.err" \
    < ./${JOB6}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 6 array with ID $JOBID6"