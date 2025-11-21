#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_megahit_bin
#BSUB -o ./launch_megahit_bin.%J.out
#BSUB -e ./launch_megahit_bin.%J.err

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
# 09 Binning
create_dir $BINNING_DIR
init_dir $CONCOCT_MEGA $CONCOCT_LOGS_O_MEGA $CONCOCT_LOGS_E_MEGA 
# --- End Create File Structure ---

# --- Launch Job ---
# Job 9A: CONCOCT Binning (depends on 8A) - MEGAHIT
echo "Launching Job 9A: CONCOCT Binning"
JOBID9A=$(bsub -J "$JOB9A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB9A_CPUS \
    -q $JOB9A_QUEUE \
    -R "rusage[mem=$JOB9A_MEMORY]" \
    -M $JOB9A_MEMORY \
    -W $JOB9A_TIME \
    -o "${CONCOCT_LOGS_O_MEGA}/megahit_concoct.09A.%J_%I.log" \
    -e "${CONCOCT_LOGS_E_MEGA}/megahit_concoct.09A.%J_%I.err" \
    < ./${JOB9A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9A array with ID $JOBID9A"