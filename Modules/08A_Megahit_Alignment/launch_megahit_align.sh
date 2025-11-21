#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_megahit_align
#BSUB -o ./launch_megahit_align.%J.out
#BSUB -e ./launch_megahit_align.%J.err

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
# 08 Alignment Outputs
create_dir $ALIGN_DIR
init_dir $ALIGN_MEGAHIT_DIR $ALIGN_MEGAHIT_LOGS_O $ALIGN_MEGAHIT_LOGS_E # MEGAHIT
# --- End Create File Structure ---

# --- Launch Job ---
# Job 8A: Align to MEGAHIT (depends on 7A)
echo "Launching Job 8A: Align to MEGAHIT"
JOBID8A=$(bsub -J "$JOB8A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB8A_CPUS \
    -q $JOB8A_QUEUE \
    -R "rusage[mem=$JOB8A_MEMORY]" \
    -M $JOB8A_MEMORY \
    -W $JOB8A_TIME \
    -o "${ALIGN_MEGAHIT_LOGS_O}/megahit_alignment.08A.%J_%I.log" \
    -e "${ALIGN_MEGAHIT_LOGS_E}/megahit_alignment.08A.%J_%I.err" \
    < ./${JOB8A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 8A array with ID $JOBID8A"