#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${READ_TAX_LOGS_O}/read_taxonomy.13.%J_%I.log"
#BSUB -e "${READ_TAX_LOGS_E}/read_taxonomy.13.%J_%I.err"

# This script runs Kraken2/Bracken taxonomy classification on reads

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX - 1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Input reads (clean, decontaminated)
PAIR1=${CONTAM_DIR}/${NAME}_1.fastq.gz
PAIR2=${CONTAM_DIR}/${NAME}_2.fastq.gz

# Output directories
OUTDIR="${READ_TAX_DIR}/${NAME}"
HUMAN_READ_DIR="${OUTDIR}/human_reads"
NONHUMAN_READ_DIR="${OUTDIR}/nonhuman_reads"

mkdir -p $OUTDIR
mkdir -p $HUMAN_READ_DIR
mkdir -p $NONHUMAN_READ_DIR

echo "Processing ${NAME}"
echo "Input: ${PAIR1}"
echo "Input: ${PAIR2}"

module load apptainer

# Run Kraken2
apptainer exec --bind ${OUTDIR}:${OUTDIR},${CONTAM_DIR}:${CONTAM_DIR},${READ_TAX_DIR}:${READ_TAX_DIR},${KRAKEN2_DB}:${KRAKEN2_DB} $KRAKEN2 \
    kraken2 --db ${KRAKEN2_DB} --paired \
    --memory-mapping \
    --classified-out ${OUTDIR}/cseqs#.fq \
    --output ${OUTDIR}/kraken_results.txt \
    --report ${OUTDIR}/kraken_report.txt \
    --use-names --threads $JOB13_CPUS \
    ${PAIR1} ${PAIR2}

# Run Bracken
REPORT="${OUTDIR}/kraken_report.txt"
RESULTS="${OUTDIR}/kraken_results.txt"
apptainer exec --bind ${OUTDIR}:${OUTDIR},${READ_TAX_DIR}:${READ_TAX_DIR},${KRAKEN2_DB}:${KRAKEN2_DB} $BRACKEN \
    est_abundance.py -i ${REPORT} \
    -o ${OUTDIR}/bracken_results.txt \
    -k ${KRAKEN2_DB}/database${KRAKEN2_KMER_SIZE}mers.kmer_distrib

# Extract human reads
TAXID=9606
HUMAN_R1="${HUMAN_READ_DIR}/r1.fq"
HUMAN_R2="${HUMAN_READ_DIR}/r2.fq"
BRACKEN_REPORT="${OUTDIR}/kraken_report_bracken_species.txt"

apptainer exec --bind ${OUTDIR}:${OUTDIR},${CONTAM_DIR}:${CONTAM_DIR},${READ_TAX_DIR}:${READ_TAX_DIR} $KRAKENTOOLS \
    extract_kraken_reads.py -k ${RESULTS} \
    -r ${BRACKEN_REPORT} -s1 ${PAIR1} -s2 ${PAIR2} \
    --taxid ${TAXID} -o ${HUMAN_R1} -o2 ${HUMAN_R2} \
    --include-children --fastq-output

gzip ${HUMAN_R1}
gzip ${HUMAN_R2}

# Extract non-human reads
NONHUMAN_R1="${NONHUMAN_READ_DIR}/r1.fq"
NONHUMAN_R2="${NONHUMAN_READ_DIR}/r2.fq"

apptainer exec --bind ${OUTDIR}:${OUTDIR},${CONTAM_DIR}:${CONTAM_DIR},${READ_TAX_DIR}:${READ_TAX_DIR} $KRAKENTOOLS \
    extract_kraken_reads.py -k ${RESULTS} \
    -r ${BRACKEN_REPORT} -s1 ${PAIR1} -s2 ${PAIR2} \
    --taxid ${TAXID} -o ${NONHUMAN_R1} -o2 ${NONHUMAN_R2} \
    --include-children --exclude --fastq-output

gzip ${NONHUMAN_R1}
gzip ${NONHUMAN_R2}

echo "Read taxonomy completed for ${NAME}"
date