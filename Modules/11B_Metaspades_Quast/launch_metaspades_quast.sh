#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_metaspades_quast
#BSUB -o ./launch_metaspades_quast.%J.out
#BSUB -e ./launch_metaspades_quast.%J.err

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
# 11 QUAST
create_dir $QUAST_DIR
init_dir $QUAST_META $QUAST_LOGS_O_META $QUAST_LOGS_E_META # metaSPAdes
# --- End Create File Structure ---

# --- Launch Job ---
# Job 11B: QUAST (depends on 9B) - metaSPAdes
echo "Launching Job 11B: QUAST"
JOBID11B=$(bsub -J "$JOB11B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB11B_CPUS \
    -q $JOB11B_QUEUE \
    -R "rusage[mem=$JOB11B_MEMORY]" \
    -M $JOB11B_MEMORY \
    -W $JOB11B_TIME \
    -o "${QUAST_LOGS_O_META}/metaspades_quast.11B.%J_%I.log" \
    -e "${QUAST_LOGS_E_META}/metaspades_quast.11B.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB11B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 11B array with ID $JOBID11B"