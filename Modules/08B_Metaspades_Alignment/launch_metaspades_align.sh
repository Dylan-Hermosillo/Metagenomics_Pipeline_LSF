#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_metaspades_align
#BSUB -o ./launch_metaspades_align.%J.out
#BSUB -e ./launch_metaspades_align.%J.err

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
init_dir $ALIGN_METASPADES_DIR $ALIGN_METASPADES_LOGS_O $ALIGN_METASPADES_LOGS_E # metaSPAdes
# --- End Create File Structure ---

# --- Launch Job ---
# Job 8B: Align to metaSPAdes (depends on 7B)
echo "Launching Job 8B: Align to metaSPAdes"
JOBID8B=$(bsub -J "$JOB8B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB8B_CPUS \
    -q $JOB8B_QUEUE \
    -R "rusage[mem=$JOB8B_MEMORY]" \
    -M $JOB8B_MEMORY \
    -W $JOB8B_TIME \
    -o "${ALIGN_METASPADES_LOGS_O}/metaspades_alignment.08B.%J_%I.log" \
    -e "${ALIGN_METASPADES_LOGS_E}/metaspades_alignment.08B.%J_%I.err" \
    < ./${JOB8B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 8B array with ID $JOBID8B"