#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_fastqc_before
#BSUB -o ./launch_fastqc_before.%J.out
#BSUB -e ./launch_fastqc_before.%J.err

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
# 03 FastQC Before Trim Outputs
init_dir $FASTQC_BEFORE $FASTQC_LOGS_O $FASTQC_LOGS_E $FASTQC_B_HTML
# --- End Create File Structure ---

# --- Launch Job ---
# Job 3: FastQC Before Trim
echo "Launching Job 3: FastQC Before Trim"
JOBID3=$(bsub -J "$JOB3[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB3_CPUS \
    -q $JOB3_QUEUE \
    -R "rusage[mem=$JOB3_MEMORY]" \
    -M $JOB3_MEMORY \
    -W $JOB3_TIME \
    -o "${FASTQC_LOGS_O}/fastqc.03.%J_%I.log" \
    -e "${FASTQC_LOGS_E}/fastqc.03.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB3}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 3 array with ID $JOBID3"