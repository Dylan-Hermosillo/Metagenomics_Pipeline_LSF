#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_kraken2
#BSUB -o ./launch_kraken2.%J.out
#BSUB -e ./launch_kraken2.%J.err

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
# 13 Reads Taxonomy Outputs
init_dir $READ_TAX_DIR $READ_TAX_LOGS_O $READ_TAX_LOGS_E # Reads
# --- End Create File Structure ---

# --- Launch Job ---
# Job 13: Read Taxonomy (depends on 05, runs independently)
echo "Launching Job 13: Read Taxonomy"
JOBID13=$(bsub -J "$JOB13[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB13_CPUS \
    -q $JOB13_QUEUE \
    -R "rusage[mem=$JOB13_MEMORY]" \
    -M $JOB13_MEMORY \
    -W $JOB13_TIME \
    -o "${READ_TAX_LOGS_O}/read_taxonomy.13.%J_%I.log" \
    -e "${READ_TAX_LOGS_E}/read_taxonomy.13.%J_%I.err" \
    < ./${JOB13}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 13 array with ID $JOBID13"
