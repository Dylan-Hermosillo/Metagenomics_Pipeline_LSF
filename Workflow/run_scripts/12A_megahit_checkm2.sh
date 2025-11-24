#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${CHECKM_LOGS_O_MEGA}/megahit_checkm.12A.%J_%I.log"
#BSUB -e "${CHECKM_LOGS_E_MEGA}/megahit_checkm.12A.%J_%I.err"

# This script runs CheckM2 on CONCOCT bins

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX - 1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Output directory
OUTDIR="${CHECKM2_MEGA}/${NAME}"
mkdir -p $OUTDIR

# Bins directory
BINS_DIR="${CONCOCT_MEGA}/${NAME}/fasta_bins"

if [[ ! -d $BINS_DIR ]]; then
    echo "Error: Bins directory not found for ${NAME}"
    exit 1
fi

NUM_BINS=$(ls ${BINS_DIR}/*.fa 2>/dev/null | wc -l)
if [[ $NUM_BINS -eq 0 ]]; then
    echo "Warning: No bins found for ${NAME}"
    exit 0
fi

echo "Processing ${NUM_BINS} bins for ${NAME}"

# Run CheckM2
module load apptainer
apptainer exec --bind ${OUTDIR}:${OUTDIR},${CONCOCT_MEGA}:${CONCOCT_MEGA},${CHECKM2_DIR}:${CHECKM2_DIR},${CHECKM2_DB}:${CHECKM2_DB} $CHECKM2 \
    checkm2 predict --threads $JOB12A_CPUS \
    --input $BINS_DIR \
    -x fa \
    --output-directory $OUTDIR \
    --database_path $CHECKM2_DB

echo "CheckM2 completed for ${NAME}"
date
