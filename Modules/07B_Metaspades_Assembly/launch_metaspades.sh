#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_metaspades
#BSUB -o ./launch_metaspades.%J.out
#BSUB -e ./launch_metaspades.%J.err

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
init_dir $METASPADES_DIR $METASPADES_LOGS_O $METASPADES_LOGS_E # metaSPAdes
# --- End Create File Structure ---

# --- Launch Job ---
# Job 7B: metaSPAdes Assembly (runs concurrently with 7A)
echo "Launching Job 7B: metaSPAdes Assembly"
JOBID7B=$(bsub -J "$JOB7B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB7B_CPUS \
    -q $JOB7B_QUEUE \
    -R "rusage[mem=$JOB7B_MEMORY]" \
    -M $JOB7B_MEMORY \
    -W $JOB7B_TIME \
    -o "${METASPADES_LOGS_O}/metaspades_assembly.07B.%J_%I.log" \
    -e "${METASPADES_LOGS_E}/metaspades_assembly.07B.%J_%I.err" \
    < ./${JOB7B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 7B array with ID $JOBID7B"