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
create_dir $WORKING_DIR
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
# 01 Reads Dir (SRA Toolkit output)
create_dir $READS_DIR $SRA_LOGS_O $SRA_LOGS_E
# 02 FastQC Before Trim Outputs
create_dir $FASTQC_BEFORE $FASTQC_LOGS_O $FASTQC_LOGS_E
# 03 Trimmomatic Outputs
create_dir $TRIM_DIR $TRIMMED $UNPAIRED $TRIM_LOGS_O $TRIM_LOGS_E
# 04 FastQC After Trim Outputs
create_dir $FASTQC_AFTER $FASTQC_AFTER_LOGS_O $FASTQC_AFTER_LOGS_E
# 05 Bowtie2 Decontamination Outputs
create_dir $CONTAM_DIR $CONTAM_LOGS_O $CONTAM_LOGS_E
# --- End Create File Structure ---

# --- Launch Pipeline Steps ---
# Job 1: SRA Prefetch
echo "Launching Job 1: SRA Prefetch"
JOBID1=$(bsub -J "$JOB1[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB1_CPUS \
    -q $JOB1_QUEUE \
    -R "rusage[mem=$JOB1_MEMORY]" \
    -W $JOB1_TIME \
    -o "${SRA_LOGS_O}/output.01A.%J_%I.log" \
    -e "${SRA_LOGS_E}/error.01A.%J_%I.log" \
    < $RUN_SCRIPTS/${JOB1}.sh | awk '{print $2}' | tr -d '<>')
echo "Submitted Job 1 array with ID $JOBID1"

# Job 2: SRA Dump
echo "Launching Job 2: SRA Dump"
JOBID2=$(bsub -J "$JOB2[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB2_CPUS \
    -q $JOB2_QUEUE \
    -R "rusage[mem=$JOB2_MEMORY]" \
    -W $JOB2_TIME \
    -w "done($JOBID1)" \
    -o "${SRA_LOGS_O}/output.01B.%J_%I.log" \
    -e "${SRA_LOGS_E}/error.01B.%J_%I.log" \
    < $RUN_SCRIPTS/${JOB2}.sh | awk '{print $2}' | tr -d '<>')
echo "Submitted Job 2 array with ID $JOBID2"

# Job 3: FastQC Before Trim
echo "Launching Job 3: FastQC Before Trim"
JOBID3=$(bsub -J "$JOB3[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB3_CPUS \
    -q $JOB3_QUEUE \
    -R "rusage[mem=$JOB3_MEMORY]" \
    -W $JOB3_TIME \
    -w "done($JOBID2)" \
    -o "${FASTQC_LOGS_O}/output.02.%J_%I.log" \
    -e "${FASTQC_LOGS_E}/error.02.%J_%I.log" \
    < $RUN_SCRIPTS/${JOB3}.sh | awk '{print $2}' | tr -d '<>')
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
    < $RUN_SCRIPTS/${JOB4}.sh | awk '{print $2}' | tr -d '<>')
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
    < $RUN_SCRIPTS/${JOB5}.sh | awk '{print $2}' | tr -d '<>')
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
    < $RUN_SCRIPTS/${JOB6}.sh | awk '{print $2}' | tr -d '<>')
echo "Submitted Job 6 array with ID $JOBID6"
# --- End Launch Pipeline Steps ---
echo "All jobs submitted successfully!"