#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${FASTQC_LOGS_O}/fastqc.03.%J_%I.log"
#BSUB -e "${FASTQC_LOGS_E}/fastqc.03.%J_%I.err"

# -------------------------
# 03_fastqc_before.sh - This script runs FastQC on raw reads before trimming
# -------------------------

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX - 1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}
# Run FastQC Before Trimming
OUTDIR=${FASTQC_BEFORE}/${NAME}
mkdir -p $OUTDIR
module load apptainer
apptainer exec --bind ${OUTDIR}:${OUTDIR},${FASTQC_BEFORE}:${FASTQC_BEFORE},${READS_DIR}:${READS_DIR} $FASTQC \
    fastqc --threads $JOB3_CPUS -o $OUTDIR \
    $READS_DIR/${NAME}/${NAME}/${NAME}_1.fastq \
    $READS_DIR/${NAME}/${NAME}/${NAME}_2.fastq

cd ${FASTQC_BEFORE}/${NAME}
if ls *.html 1> /dev/null 2>&1; then
    mv *.html ${FASTQC_B_HTML}
else
    echo "Warning: No HTML files found"
fi
