#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${FASTQC_AFTER_LOGS_O}/fastqc.06.%J_%I.log"
#BSUB -e "${FASTQC_AFTER_LOGS_E}/fastqc.06_%J_%I.err"

# -------------------------
# 06_fastqc_after.sh - This script runs FastQC on raw reads before trimming
# -------------------------

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX -1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Run FastQC After Trimming
module load apptainer
apptainer exec --bind ${FASTQC_AFTER}:${FASTQC_AFTER},${TRIMMED}:${TRIMMED} $FASTQC \
    fastqc --threads $JOB6_CPUS -o $FASTQC_AFTER \
    $TRIMMED/${NAME}_R1_paired.fastq.gz \
    $TRIMMED/${NAME}_R2_paired.fastq.gz

cd ${FASTQC_AFTER}
if ls *.html 1> /dev/null 2>&1; then
    mv *.html ${FASTQC_A_HTML}
else
    echo "Warning: No HTML files found"
fi
