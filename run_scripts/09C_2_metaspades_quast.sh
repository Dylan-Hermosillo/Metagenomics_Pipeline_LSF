#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${QUAST_LOGS_META_O}/quast.09C.%J_%I.log"
#BSUB -e "${QUAST_LOGS_META_E}/quast.09C.%J_%I.err"

# This script runs QUAST on concatenated binned contigs

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX - 1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Output directory
OUTDIR="${QUAST_META}/${NAME}"
mkdir -p $OUTDIR

# Concatenated contigs from binning
CONCOCT_CONTIGS="${CONCOCT_META}/${NAME}.all_contigs.fna"

if [[ ! -f $CONCOCT_CONTIGS ]]; then
    echo "Error: Concatenated contigs not found for ${NAME}"
    exit 1
fi

echo "Processing ${NAME}"

# Run QUAST
module load apptainer
apptainer exec --bind ${CONCOCT_META}:${CONCOCT_META},${QUAST_META}:${QUAST_META} $QUAST \
    quast -t $JOB9C_CPUS \
    -o $OUTDIR \
    -m 500 \
    $CONCOCT_CONTIGS

echo "QUAST completed for ${NAME}"
date
