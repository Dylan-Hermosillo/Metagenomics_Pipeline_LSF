#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${ALIGN_MEGAHIT_LOGS_O}/align_megahit.08A.%J_%I.log"
#BSUB -e "${ALIGN_MEGAHIT_LOGS_E}/align_megahit.08A.%J_%I.err"

# -------------------------
# 08A_align_megahit.sh This script aligns clean reads to MEGAHIT assembly using BWA
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

# Output directory for this sample
OUTDIR="${ALIGN_MEGAHIT_DIR}/${NAME}"
mkdir -p $OUTDIR

# Assembly to align to
CONTIGS="${MEGAHIT_DIR}/${NAME}/final.contigs.fa"

if [[ ! -f $CONTIGS ]]; then
    echo "Warning: MEGAHIT assembly not found for ${NAME}"
    exit 1
fi

echo "Processing ${NAME}"

# Index assembly
module load apptainer
apptainer exec --bind ${MEGAHIT_DIR}:${MEGAHIT_DIR} $BWA \
    bwa index ${CONTIGS}

# Align reads
apptainer exec --bind ${CONTAM_DIR}:${CONTAM_DIR},${MEGAHIT_DIR}:${MEGAHIT_DIR},${ALIGN_MEGAHIT_DIR}:${ALIGN_MEGAHIT_DIR} $BWA \
    bwa mem -t $JOB8A_CPUS ${CONTIGS} ${PAIR1} ${PAIR2} > ${OUTDIR}/result.sam

# Convert to BAM
apptainer exec --bind ${ALIGN_MEGAHIT_DIR}:${ALIGN_MEGAHIT_DIR} $SAMTOOLS \
    samtools view -b -F 4 ${OUTDIR}/result.sam > ${OUTDIR}/result.bam

# Sort BAM
apptainer exec --bind ${ALIGN_MEGAHIT_DIR}:${ALIGN_MEGAHIT_DIR} $SAMTOOLS \
    samtools sort ${OUTDIR}/result.bam > ${OUTDIR}/sorted.bam

# Index BAM
apptainer exec --bind ${ALIGN_MEGAHIT_DIR}:${ALIGN_MEGAHIT_DIR} $SAMTOOLS \
    samtools index ${OUTDIR}/sorted.bam

# Clean up
rm ${OUTDIR}/result.sam ${OUTDIR}/result.bam

echo "MEGAHIT alignment completed for ${NAME}"
date
