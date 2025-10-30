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
# get sample list & export number of samples
if [[ ! -f ${XFILE} ]]; then
    echo "Sample list file ${XFILE} not found!"
    exit 1
fi
# get number of jobs
export NUM_JOB=$(wc -l < "${XFILE}")
# --- End Housekeeping ---

# --- Create File Structure ---
# 00 Working Dir (should be made already and have the xfile inside...
# but if the SRR/ERR ids are elsewhere, create working dir)
create_dir $WORKING_DIR
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
bsub -J "$JOB1[1-$NUM_JOB]%NUM_JOB" \
    -n $JOB1_CPUS \
    -q $JOB1_QUEUE \
    -R "rusage[mem=$JOB1_MEMORY]" \
    -W $JOB1_TIME \
    < $RUN_SCRIPTS/$JOB1
# Job 2: SRA Dump
echo "Launching Job 2: SRA Dump"
bsub -J "$JOB2[1-$NUM_JOB]%NUM_JOB" \
    -n $JOB2_CPUS \
    -q $JOB2_QUEUE \
    -R "rusage[mem=$JOB2_MEMORY]" \
    -W $JOB2_TIME \
    -w "done($JOB1)" \
    < $RUN_SCRIPTS/$JOB2
# Job 3: FastQC Before Trim
echo "Launching Job 3: FastQC Before Trim"
bsub -J "$JOB3[1-$NUM_JOB]%NUM_JOB" \
    -n $JOB3_CPUS \
    -q $JOB3_QUEUE \
    -R "rusage[mem=$JOB3_MEMORY]" \
    -W $JOB3_TIME \
    -w "done($JOB2)" \
    < $RUN_SCRIPTS/$JOB3
# Job 4: Trimmomatic
echo "Launching Job 4: Trimmomatic"
bsub -J "$JOB4[1-$NUM_JOB]%NUM_JOB" \
    -n $JOB4_CPUS \
    -q $JOB4_QUEUE \
    -R "rusage[mem=$JOB4_MEMORY]" \
    -W $JOB4_TIME \
    -w "done($JOB3)" \
    < $RUN_SCRIPTS/$JOB4
# Job 5: Bowtie2 Decontamination
echo "Launching Job 5: Bowtie2 Decontamination"
bsub -J "$JOB5[1-$NUM_JOB]%NUM_JOB" \
    -n $JOB5_CPUS \
    -q $JOB5_QUEUE \
    -R "rusage[mem=$JOB5_MEMORY]" \
    -W $JOB5_TIME \
    -w "done($JOB4)" \
    < $RUN_SCRIPTS/$JOB5
# Job 6: FastQC After Trim
echo "Launching Job 6: FastQC After Trim"
bsub -J "$JOB6[1-$NUM_JOB]%NUM_JOB" \
    -n $JOB6_CPUS \
    -q $JOB6_QUEUE \
    -R "rusage[mem=$JOB6_MEMORY]" \
    -W $JOB6_TIME \
    -w "done($JOB4)" \
    < $RUN_SCRIPTS/$JOB6    
# --- End Launch Pipeline Steps ---