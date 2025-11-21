#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_megahit_kraken2
#BSUB -o ./launch_megahit_kraken2.%J.out
#BSUB -e ./launch_megahit_kraken2.%J.err

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
# 14 Contig Taxonomy Outputs
create_dir $CONTIG_TAX_DIR
init_dir $CONTIG_TAX_DIR_MEGA $CONTIG_LOGS_O_MEGA $CONTIG_LOGS_E_MEGA # MEGAHIT
# --- End Create File Structure ---

# --- Launch Job ---
# Job 14A: Contig Taxonomy (depends on 7A) MEGAHIT
echo "Launching Job 14A: Contig Taxonomy"
JOBID14A=$(bsub -J "$JOB14A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB14A_CPUS \
    -q $JOB14A_QUEUE \
    -R "rusage[mem=$JOB14A_MEMORY]" \
    -M $JOB14A_MEMORY \
    -W $JOB14A_TIME \
    -o "${CONTIG_TAX_LOGS_O}/contig_taxonomy.14A.%J_%I.log" \
    -e "${CONTIG_TAX_LOGS_E}/contig_taxonomy.14A.%J_%I.err" \
    < ./${JOB14A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 14A array with ID $JOBID14A"
