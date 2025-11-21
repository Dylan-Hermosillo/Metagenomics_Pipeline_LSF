#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${ALIGN_METASPADES_LOGS_O}/metaspades_alignment.08B.%J_%I.log"
#BSUB -e "${ALIGN_METASPADES_LOGS_E}/metaspades_alignment.08B.%J_%I.err"

# -------------------------
# 08B_align_metaspades.sh This script aligns clean reads to metaSPAdes assembly
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
OUTDIR="${ALIGN_METASPADES_DIR}/${NAME}"
mkdir -p $OUTDIR

# Assembly to align to
CONTIGS="${METASPADES_DIR}/${NAME}/contigs.fasta"

if [[ ! -f $CONTIGS ]]; then
    echo "Warning: metaSPAdes assembly not found for ${NAME}"
    exit 1
fi

echo "Processing ${NAME}"

# Index assembly
module load apptainer
apptainer exec --bind ${METASPADES_DIR}:${METASPADES_DIR} $BWA \
    bwa index ${CONTIGS}

# Align reads
apptainer exec --bind ${CONTAM_DIR}:${CONTAM_DIR},${METASPADES_DIR}:${METASPADES_DIR},${ALIGN_METASPADES_DIR}:${ALIGN_METASPADES_DIR} $BWA \
    bwa mem -t $JOB8B_CPUS ${CONTIGS} ${PAIR1} ${PAIR2} > ${OUTDIR}/result.sam

# Convert to BAM
apptainer exec --bind ${ALIGN_METASPADES_DIR}:${ALIGN_METASPADES_DIR} $SAMTOOLS \
    samtools view -b -F 4 ${OUTDIR}/result.sam > ${OUTDIR}/result.bam

# Sort BAM
apptainer exec --bind ${ALIGN_METASPADES_DIR}:${ALIGN_METASPADES_DIR} $SAMTOOLS \
    samtools sort ${OUTDIR}/result.bam > ${OUTDIR}/sorted.bam

# Index BAM
apptainer exec --bind ${ALIGN_METASPADES_DIR}:${ALIGN_METASPADES_DIR} $SAMTOOLS \
    samtools index ${OUTDIR}/sorted.bam

# Clean up
rm ${OUTDIR}/result.sam ${OUTDIR}/result.bam

echo "metaSPAdes alignment completed for ${NAME}"
date
