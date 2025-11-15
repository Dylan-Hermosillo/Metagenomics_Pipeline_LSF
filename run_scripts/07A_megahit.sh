#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${MEGAHIT_LOGS_O}/megahit.07A.%J_%I.log"
#BSUB -e "${MEGAHIT_LOGS_E}/megahit.07A.%J_%I.err"

# -------------------------
# 07A_megahit.sh - This script runs MEGAHIT assembly on decontaminated reads
# -------------------------

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX -1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Input reads (clean, decontaminated)
PAIR1=${CONTAM_DIR}/${NAME}_1.fastq.gz
PAIR2=${CONTAM_DIR}/${NAME}_2.fastq.gz

# Run MEGAHIT
module load apptainer
apptainer exec --bind ${CONTAM_DIR}:${CONTAM_DIR},${MEGAHIT_DIR}:${MEGAHIT_DIR} $MEGAHIT \
    megahit \
    -1 $PAIR1 \
    -2 $PAIR2 \
    -o $MEGAHIT_DIR \
    --num-cpu-threads $JOB7A_CPUS \
    --memory $JOB7A_MEMORY_GB

echo "MEGAHIT assembly completed for ${NAME}"
date
