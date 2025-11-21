#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_bowtie2
#BSUB -o ./launch_bowtie2.%J.out
#BSUB -e ./launch_bowtie2.%J.err

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
# 05 Bowtie2 Decontamination Outputs
init_dir $CONTAM_DIR $CONTAM_LOGS_O $CONTAM_LOGS_E
# --- End Create File Structure ---

# --- Launch Job ---
# Job 5: Bowtie2 Decontamination
echo "Launching Job 5: Bowtie2 Decontamination"
JOBID5=$(bsub -J "$JOB5[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB5_CPUS \
    -q $JOB5_QUEUE \
    -R "rusage[mem=$JOB5_MEMORY]" \
    -M $JOB5_MEMORY \
    -W $JOB5_TIME \
    -o "${CONTAM_LOGS_O}/bowtie2.05.%J_%I.log" \
    -e "${CONTAM_LOGS_E}/bowtie2.05.%J_%I.err" \
    < ./${JOB5}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 5 array with ID $JOBID5"