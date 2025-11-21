#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${CONTAM_LOGS_O}/bowtie2.05.%j_%I.log"
#BSUB -e "${CONTAM_LOGS_E}/bowtie2.05.%j_%I.err"

# -------------------------
# 05_bowtie2.sh - This script runs Bowtie2 to decontaminate reads
# -------------------------

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX - 1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Input reads (from Trimmomatic)
PAIR1=${TRIMMED}/${NAME}_R1_paired.fastq.gz
PAIR2=${TRIMMED}/${NAME}_R2_paired.fastq.gz

# Output paths
BOWTIE_NAME="${CONTAM_DIR}/${NAME}_%.fastq.gz"
SAM_NAME="${CONTAM_DIR}/${NAME}_human_removed.sam"
MET_NAME="${CONTAM_DIR}/${NAME}_hostmap.log"

# Get reference DB directory for bind mount
REF_DB_DIR=$(dirname $REF_DB)

# Run Bowtie2 Decontamination
module load apptainer
echo "PAIR1=$PAIR1"
echo "PAIR2=$PAIR2"
echo "REF_DB=$REF_DB"
echo "REF_DB_DIR=$REF_DB_DIR"
echo "BOWTIE2=$BOWTIE2"
apptainer exec $BOWTIE2 bowtie2 --version
apptainer exec --bind ${TRIMMED}:${TRIMMED},${CONTAM_DIR}:${CONTAM_DIR},${REF_DB_DIR}:${REF_DB_DIR} $BOWTIE2 bowtie2 \
    -p $JOB5_CPUS \
    -x $REF_DB \
    -1 $PAIR1 \
    -2 $PAIR2 \
    --un-conc-gz $BOWTIE_NAME 1> $SAM_NAME 2> $MET_NAME

rm $SAM_NAME
