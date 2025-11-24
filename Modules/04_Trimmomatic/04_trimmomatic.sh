#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${TRIM_LOGS_O}/trim.04.%J_%I.log"
#BSUB -e "${TRIM_LOGS_E}/trim.04.%J_%I.err"

# -------------------------
# 04_trimmomatic.sh - This script runs Trimmomatic to trim reads
# -------------------------

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX - 1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Get adapter directory for bind mount
ADAPTER_DIR=$(dirname $ADAPTERS)

# Run Trimmomatic
module load apptainer
apptainer exec --bind ${READS_DIR}:${READS_DIR},${TRIM_DIR}:${TRIM_DIR},${ADAPTER_DIR}:${ADAPTER_DIR} $TRIMMOMATIC trimmomatic PE -phred33 -threads $JOB4_CPUS \
    $READS_DIR/${NAME}/${NAME}/${NAME}_1.fastq $READS_DIR/${NAME}/${NAME}/${NAME}_2.fastq \
    $TRIMMED/${NAME}_R1_paired.fastq.gz $UNPAIRED/${NAME}_R1_unpaired.fastq.gz \
    $TRIMMED/${NAME}_R2_paired.fastq.gz $UNPAIRED/${NAME}_R2_unpaired.fastq.gz \
    ILLUMINACLIP:${ADAPTERS}:${TRIM_ILLUMINACLIP} SLIDINGWINDOW:${TRIM_SLIDINGWINDOW} MINLEN:${TRIM_MINLEN} HEADCROP:${TRIM_HEADCROP}