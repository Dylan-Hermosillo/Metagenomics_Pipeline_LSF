#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${TRIM_LOGS_O}/output.03.%J_%I.log"
#BSUB -e "${TRIM_LOGS_E}/error.03.%J_%I.log"

# This script runs Trimmomatic to trim reads

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX -1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Run Trimmomatic
module load apptainer
apptainer exec $TRIMMOMATIC trimmomatic PE -phred33 -threads $JOB4_CPUS \
    $READS_DIR/${NAME}/${NAME}_1.fastq.gz $READS_DIR/${NAME}/${NAME}_2.fastq.gz \
    $TRIMMED/${NAME}_1.fastq.gz $UNPAIRED/${NAME}_1.fastq.gz \
    $TRIMMED/${NAME}_2.fastq.gz $UNPAIRED/${NAME}_2.fastq.gz \
    ILLUMINACLIP:TruSeq3-PE-2.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:100 HEADCROP:10