#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${TRIM_LOGS_O}/output.03.%J_%I.log"
#BSUB -e "${TRIM_LOGS_E}/error.03.%J_%

# This script runs Bowtie2 to decontaminate reads

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX -1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# reads
PAIR1=${TRIMMED}/${NAME}_1.fastq.gz
PAIR2=${TRIMMED}/${NAME}_2.fastq.gz

### reads with human removed
BOWTIE_NAME="${CONTAM_DIR}/${NAME}_%.fastq.gz"
SAM_NAME="${CONTAM_DIR}/${NAME}_human_removed.sam"
### reads mapped to human
MET_NAME="${CONTAM_DIR}/${NAME}_hostmap.log"

# Run Bowtie2 Decontamination
module load apptainer
apptainer exec $BOWTIE2 bowtie2\
    -p $JOB4_CPUS \
    -x $REF_DB \
    -1 $PAIR1 \
    -2 $PAIR2 \
    --un-conc-gz $BOWTIE_NAME 1> $SAM_NAME 2> $MET_NAME

rm $SAM_NAME