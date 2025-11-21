#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_metaspades_bin
#BSUB -o ./launch_metaspades_bin.%J.out
#BSUB -e ./launch_metaspades_bin.%J.err

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
init_dir $CONCOCT_META $CONCOCT_LOGS_O_META $CONCOCT_LOGS_E_META # metaSPAdes
# --- End Create File Structure ---

# --- Launch Job ---
# Job 9B: CONCOCT Binning (depends on 8B) - metaSPAdes
echo "Launching Job 9B: CONCOCT Binning"
JOBID9B=$(bsub -J "$JOB9B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB9B_CPUS \
    -q $JOB9B_QUEUE \
    -R "rusage[mem=$JOB9B_MEMORY]" \
    -M $JOB9B_MEMORY \
    -W $JOB9B_TIME \
    -o "${CONCOCT_LOGS_O_META}/metaspades_concoct.09B.%J_%I.log" \
    -e "${CONCOCT_LOGS_E_META}/metaspades_concoct.09B.%J_%I.err" \
    < ./${JOB9B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9B array with ID $JOBID9B"
