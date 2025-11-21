#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_metaspades_kraken2
#BSUB -o ./launch_metaspades_kraken2.%J.out
#BSUB -e ./launch_metaspades_kraken2.%J.err

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
create_dir $CONTIG_TAX_DIR
init_dir $CONTIG_TAX_DIR_META $CONTIG_LOGS_O_META $CONTIG_LOGS_E_META # metaSPAdes
# --- End Create File Structure ---

# --- Launch Job ---
# Job 14B: Contig Taxonomy (depends on 7A) metaSPAdes
echo "Launching Job 14B: Contig Taxonomy"
JOBID14B=$(bsub -J "$JOB14B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB14B_CPUS \
    -q $JOB14B_QUEUE \
    -R "rusage[mem=$JOB14B_MEMORY]" \
    -M $JOB14B_MEMORY \
    -W $JOB14B_TIME \
    -o "${CONTIG_TAX_LOGS_O}/contig_taxonomy.14A.%J_%I.log" \
    -e "${CONTIG_TAX_LOGS_E}/contig_taxonomy.14A.%J_%I.err" \
    < ./${JOB14B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 14B array with ID $JOBID14B"
