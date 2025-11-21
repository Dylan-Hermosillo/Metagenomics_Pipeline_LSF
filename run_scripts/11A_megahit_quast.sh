#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${QUAST_LOGS_O_MEGA}/megahit_quast.11A.%J_%I.log"
#BSUB -e "${QUAST_LOGS_E_MEGA}/megahit_quast.11A.%J_%I.err"

# This script runs QUAST on concatenated binned contigs

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX - 1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Output directory
OUTDIR="${QUAST_MEGA}/${NAME}"
mkdir -p $OUTDIR

# Concatenated contigs from binning
CONCOCT_CONTIGS="${CONCOCT_MEGA}/${NAME}.all_contigs.fna"

if [[ ! -f $CONCOCT_CONTIGS ]]; then
    echo "Error: Concatenated contigs not found for ${NAME}"
    exit 1
fi

echo "Processing ${NAME}"

# Run QUAST
module load apptainer
apptainer exec --bind ${CONCOCT_MEGA}:${CONCOCT_MEGA},${QUAST_MEGA}:${QUAST_MEGA} $QUAST \
    quast -t $JOB11A_CPUS \
    -o $OUTDIR \
    -m 500 \
    $CONCOCT_CONTIGS

echo "QUAST completed for ${NAME}"
date
