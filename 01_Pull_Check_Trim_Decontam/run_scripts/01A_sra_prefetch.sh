#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${SRA_LOGS_O}/output.01A.%J_%I.log""
#BSUB -e "${SRA_LOGS_E}/error.01A.%J_%I.log"

# This script runs the SRA Toolkit to prefetch SRA files

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX -1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Run SRA Prefetch
module load apptainer
apptainer exec $SRA_TOOLKIT prefetch $NAME -O $READS_DIR