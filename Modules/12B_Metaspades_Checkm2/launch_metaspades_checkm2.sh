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
# 12 CheckM2
create_dir $CHECKM_DIR2
init_dir $CHECKM2_META $CHECKM2_LOGS_O_META $CHECKM2_LOGS_E_META # metaSPAdes
# --- End Create File Structure ---

# --- Launch Job ---
# Job 12B: CheckM2 (depends on 9A2, runs concurrently with 9B/9C) metaSPAdes
echo "Launching Job 12B: CheckM2"
JOBID12B=$(bsub -J "$JOB12B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB12B_CPUS \
    -q $JOB12B_QUEUE \
    -R "rusage[mem=$JOB12B_MEMORY]" \
    -M $JOB12B_MEMORY \
    -W $JOB12B_TIME \
    -o "${CHECKM_LOGS_O_META}/metaspades_checkm.12B.%J_%I.log" \
    -e "${CHECKM_LOGS_E_META}/metaspades_checkm.12B.%J_%I.err" \
    < ./${JOB12B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9D array with ID $JOBID9D2"