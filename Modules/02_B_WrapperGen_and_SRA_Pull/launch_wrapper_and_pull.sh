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
# 01 In/Out for Wrapper Generation
init_dir $WRAP_OUT $WRAP_SCRIPTS $WRAP_LOGS_O $WRAP_LOGS_E
# 02 Reads Dir (SRA Toolkit output)
init_dir $READS_DIR $SRA_LOGS_O $SRA_LOGS_E
# --- End Create File Structure ---

# --- Launch Job ---
# Job 1: Generate LSF Wrappers
echo "Launching Job 1: LSF Wrapper Generation"
JOBID1=$(bsub -J "$JOB1[1-$NUM_JOB]%$NUM_JOB" \
     -n $JOB1_CPUS \
     -q $JOB1_QUEUE \
     -R "rusage[mem=$JOB1_MEMORY]" \
     -M $JOB1_MEMORY \
     -o "${WRAP_LOGS_O}/wrapper.gen.%J.%I.log" \
     -e "${WRAP_LOGS_E}/wrapper.gen.%J.%I.err" \
     -W $JOB1_TIME \
     < ./${JOB1}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 1 array with ID $JOBID1"

# Job 2: SRA Download
AGGREGATE_FILE="${RUN_SCRIPTS}/aggregate_prefetch_wrappers.txt"
# Verify aggregate file exists
if [[ ! -s "$AGGREGATE_FILE" ]]; then
    echo "ERROR: No wrappers were generated!"
    echo "Check logs in: $WRAP_LOGS_E/"
    exit 1
fi
echo "Launching Job 2: SRA Download (parallel on login node)"
if [[ -s "$AGGREGATE_FILE" ]]; then
    # Execute all wrappers in parallel on login node
    START_TIME=$(date +%s)
    cat "$AGGREGATE_FILE" | xargs -P $JOB2_CPUS -I {} bash {}
    JOB2_EXIT=$?
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    if [[ $JOB2_EXIT -ne 0 ]]; then
        echo "ERROR: Job 2 (parallel execution) failed with exit code $JOB2_EXIT"
        exit 1
    fi
fi
echo "Job 2 completed successfully in ${DURATION}s"