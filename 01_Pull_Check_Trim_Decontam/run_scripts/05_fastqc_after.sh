#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${FASTQC_AFTER_LOGS_O}/output.01A.%J_%I.log""
#BSUB -e "${FASTQC_AFTER_LOGS_E}/error.01A.%J_%I.log"

# This script runs FastQC on raw reads before trimming

# Log info
pwd; hostname; date
source ./config.sh
# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX -1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Run FastQC Before Trimming
module load apptainer
apptainer exec $FASTQC fastqc --threads $JOB6_CPUS \
-o $FASTQC_AFTER $TRIMMED/${NAME}_*.fastq*