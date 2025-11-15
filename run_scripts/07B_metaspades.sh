#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${METASPADES_LOGS_O}/metaspades.07B.%J_%I.log"
#BSUB -e "${METASPADES_LOGS_E}/metaspades.07B.%J_%I.err"

# -------------------------
# 07B_metaspades.sh - This script runs metaSPAdes assembly on decontaminated reads
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

# Run metaSPAdes
module load apptainer
apptainer exec --bind ${CONTAM_DIR}:${CONTAM_DIR},${METASPADES_DIR}:${METASPADES_DIR} $SPADES \
    metaspades.py \
    -1 $PAIR1 \
    -2 $PAIR2 \
    -o $METASPADES_DIR/${NAME} \
    --threads $JOB7B_CPUS \
    --memory $JOB7B_MEMORY_GB

echo "metaSPAdes assembly completed for ${NAME}"
date
