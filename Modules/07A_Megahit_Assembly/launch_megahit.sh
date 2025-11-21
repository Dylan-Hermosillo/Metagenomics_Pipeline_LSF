#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_megahit
#BSUB -o ./launch_megahit.%J.out
#BSUB -e ./launch_megahit.%J.err

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
# 07 Assemblers
create_dir $ASSEM_DIR
init_dir $MEGAHIT_DIR $MEGAHIT_LOGS_O $MEGAHIT_LOGS_E # MEGAHIT
# --- End Create File Structure ---

# --- Launch Job ---
# Job 7A: MEGAHIT Assembly (runs concurrently with 7B)
echo "Launching Job 7A: MEGAHIT Assembly"
JOBID7A=$(bsub -J "$JOB7A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB7A_CPUS \
    -q $JOB7A_QUEUE \
    -R "rusage[mem=$JOB7A_MEMORY]" \
    -M $JOB7A_MEMORY \
    -W $JOB7A_TIME \
    -o "${MEGAHIT_LOGS_O}/megahit_assembly.07A.%J_%I.log" \
    -e "${MEGAHIT_LOGS_E}/megahit_assembly.07A.%J_%I.err" \
    < ./${JOB7A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 7A array with ID $JOBID7A"