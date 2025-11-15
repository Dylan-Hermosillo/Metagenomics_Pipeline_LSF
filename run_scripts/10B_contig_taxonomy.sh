#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${CONTIG_TAX_LOGS_O}/contig_taxonomy.10B.%J_%I.log"
#BSUB -e "${CONTIG_TAX_LOGS_E}/contig_taxonomy.10B.%J_%I.err"

# This script runs Kraken2/Bracken taxonomy classification on contigs

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX -1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Input contigs
CONTIGS="${MEGAHIT_DIR}/${NAME}/final.contigs.fa"

# Output directories
OUTDIR="${CONTIG_TAX_DIR}/${NAME}"
HUMAN_CONTIG_DIR="${OUTDIR}/human_contigs"
NONHUMAN_CONTIG_DIR="${OUTDIR}/nonhuman_contigs"

mkdir -p $OUTDIR
mkdir -p $HUMAN_CONTIG_DIR
mkdir -p $NONHUMAN_CONTIG_DIR

if [[ ! -f $CONTIGS ]]; then
    echo "Error: MEGAHIT contigs not found for ${NAME}"
    exit 1
fi

echo "Processing ${NAME}"

module load apptainer

# Run Kraken2
apptainer exec --bind ${MEGAHIT_DIR}:${MEGAHIT_DIR},${CONTIG_TAX_DIR}:${CONTIG_TAX_DIR},${KRAKEN2_DB}:${KRAKEN2_DB} $KRAKEN \
    kraken2 --db ${KRAKEN2_DB} \
    --classified-out ${OUTDIR}/cseqs#.fa \
    --output ${OUTDIR}/kraken_results.txt \
    --report ${OUTDIR}/kraken_report.txt \
    --use-names --threads $JOB10B_CPUS \
    ${CONTIGS}

# Run Bracken
REPORT="${OUTDIR}/kraken_report.txt"
RESULTS="${OUTDIR}/kraken_results.txt"
apptainer exec --bind ${CONTIG_TAX_DIR}:${CONTIG_TAX_DIR},${KRAKEN2_DB}:${KRAKEN2_DB} $BRACKEN \
    est_abundance.py -i ${REPORT} \
    -o ${OUTDIR}/bracken_results.txt \
    -k ${KRAKEN2_DB}/database${KRAKEN_KMER_SIZE}mers.kmer_distrib

# Extract human contigs
TAXID=9606
HUMAN_CONTIGS="${HUMAN_CONTIG_DIR}/contigs.fa"
BRACKEN_REPORT="${OUTDIR}/kraken_report_bracken_species.txt"

apptainer exec --bind ${MEGAHIT_DIR}:${MEGAHIT_DIR},${CONTIG_TAX_DIR}:${CONTIG_TAX_DIR} $KRAKENTOOLS \
    extract_kraken_reads.py -k ${RESULTS} \
    -r ${BRACKEN_REPORT} -s1 ${CONTIGS} \
    --taxid ${TAXID} -o ${HUMAN_CONTIGS} \
    --include-children

if [[ -f "${HUMAN_CONTIGS}" ]]; then
    gzip ${HUMAN_CONTIGS}
fi

# Extract non-human contigs
NONHUMAN_CONTIGS="${NONHUMAN_CONTIG_DIR}/contigs.fa"

apptainer exec --bind ${MEGAHIT_DIR}:${MEGAHIT_DIR},${CONTIG_TAX_DIR}:${CONTIG_TAX_DIR} $KRAKENTOOLS \
    extract_kraken_reads.py -k ${RESULTS} \
    -r ${BRACKEN_REPORT} -s1 ${CONTIGS} \
    --taxid ${TAXID} -o ${NONHUMAN_CONTIGS} \
    --include-children --exclude

if [[ -f "${NONHUMAN_CONTIGS}" ]]; then
    gzip ${NONHUMAN_CONTIGS}
fi

echo "Contig taxonomy completed for ${NAME}"
date
