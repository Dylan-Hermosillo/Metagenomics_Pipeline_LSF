#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_pipeline_lsf
#BSUB -o launch_pipeline_lsf.%J.out
#BSUB -e launch_pipeline_lsf.%J.err

# NOTE: MAKE ALL PARAMETER CHANGES IN THE CONFIG.SH FILE!!!

# --- Housekeeping ---
# load config
source ./config.sh
# Working Dir -- should be made already but just in case...
create_dir $WORKING_DIR $SCRIPTS_DIR
# get sample list & export number of samples
if [[ ! -f ${XFILE} ]]; then
    echo "Sample list file ${XFILE} not found!"
    exit 1
fi
# get number of jobs
export NUM_JOB=$(wc -l < "${XFILE}")
echo $NUM_JOB "jobs to be launched."
# --- End Housekeeping ---

# --- Create File Structure ---
# 01 In/Out for Wrapper Generation
create_dir $WRAP_IN $WRAP_OUT $WRAP_SCRIPTS $WRAP_OUT $WRAP_ERR
# 02 Reads Dir (SRA Toolkit output)
create_dir $READS_DIR $SRA_LOGS_O $SRA_LOGS_E
# 03 FastQC Before Trim Outputs
create_dir $FASTQC_BEFORE $FASTQC_LOGS_O $FASTQC_LOGS_E
# 04 Trimmomatic Outputs
create_dir $TRIM_DIR $TRIMMED $UNPAIRED $TRIM_LOGS_O $TRIM_LOGS_E
# 05 FastQC After Trim Outputs
create_dir $FASTQC_AFTER $FASTQC_AFTER_LOGS_O $FASTQC_AFTER_LOGS_E
# 06 Bowtie2 Decontamination Outputs
create_dir $CONTAM_DIR $CONTAM_LOGS_O $CONTAM_LOGS_E
# --- End Create File Structure ---

# --- Launch Pipeline Steps ---
# Job 1: Generate LSF Wrappers
echo "launching Job 1: LSF Wrapper Generation"
JOBID1=$(bsub -J "$JOB1[1-$NUM_JOB]%$CHUNK_SIZE" \
     -n $JOB1_CPUS \
     -q $JOB1_QUEUE \
     -R "rusage[mem=$JOB1_MEMORY]" \
     -o "${WRAP_OUT}/wrapper.gen.%J.%I.log" \
     -e "${WRAP_ERR}/wrapper.gen.%J.%I.err" \
     -W $JOB1_TIME \
     < ${SCRIPTS_DIR}/01_sra_prefetch.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 1 array with id $JOBID1"
bwait -w "done($JOBID1)"
# Job 2: SRA 
AGGREGATE_FILE="${SCRIPTS_DIR}/aggregate_prefetch_wrappers.txt"
# Verify aggregate file exists
if [[ ! -s "$AGGREGATE_FILE" ]]; then
    echo "ERROR: No wrappers were generated!"
    echo "Check logs in: $WRAPPER_LOGS_E/"
    exit 1
fi
echo "NOTE: Running on login node (requires internet access)"
if [[ -s "$AGGREGATE_FILE" ]]; then
    # Execute all wrappers in parallel on login node
    START_TIME=$(date +%s)
    cat "$AGGREGATE_FILE" | xargs -P $JOB2_CPUS -I {} bash {}
    JOB2_EXIT=$?
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
else
    echo "ERROR: Job 2 (parallel execution) failed with exit code $JOB2_EXIT"
    exit 1
fi
echo "Job 2 completed successfully in ${DURATION}s at $(date)"
# Job 3: FastQC Before Trim
echo "Launching Job 3: FastQC Before Trim"
JOBID3=$(bsub -J "$JOB3[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB3_CPUS \
    -q $JOB3_QUEUE \
    -R "rusage[mem=$JOB3_MEMORY]" \
    -W $JOB3_TIME \
    -o "${FASTQC_LOGS_O}/output.02.%J_%I.log" \
    -e "${FASTQC_LOGS_E}/error.02.%J_%I.log" \
    < $RUN_SCRIPTS/${JOB3}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 3 array with ID $JOBID3"
# Job 4: Trimmomatic
echo "Launching Job 4: Trimmomatic"
JOBID4=$(bsub -J "$JOB4[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB4_CPUS \
    -q $JOB4_QUEUE \
    -R "rusage[mem=$JOB4_MEMORY]" \
    -W $JOB4_TIME \
    -w "done($JOBID3)" \
    -o "${TRIM_LOGS_O}/output.03.%J_%I.log" \
    -e "${TRIM_LOGS_E}/error.03.%J_%I.log" \
    < $RUN_SCRIPTS/${JOB4}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 4 array with ID $JOBID4"
# Job 5: Bowtie2 Decontamination
echo "Launching Job 5: Bowtie2 Decontamination"
JOBID5=$(bsub -J "$JOB5[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB5_CPUS \
    -q $JOB5_QUEUE \
    -R "rusage[mem=$JOB5_MEMORY]" \
    -W $JOB5_TIME \
    -w "done($JOBID4)" \
    -o "${CONTAM_LOGS_O}/output.04.%J_%I.log" \
    -e "${CONTAM_LOGS_E}/error.04.%J_%I.log" \
    < $RUN_SCRIPTS/${JOB5}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 5 array with ID $JOBID5"
# Job 6: FastQC After Trim
echo "Launching Job 6: FastQC After Trim"
JOBID6=$(bsub -J "$JOB6[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB6_CPUS \
    -q $JOB6_QUEUE \
    -R "rusage[mem=$JOB6_MEMORY]" \
    -W $JOB6_TIME \
    -w "done($JOBID4)" \
    -o "${FASTQC_AFTER_LOGS_O}/output.05.%J_%I.log" \
    -e "${FASTQC_AFTER_LOGS_E}/error.05.%J_%I.log" \
    < $RUN_SCRIPTS/${JOB6}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 6 array with ID $JOBID6"
# --- End Launch Pipeline Steps ---
echo "All jobs submitted successfully!"