#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${CONCOCT_LOGS_O_META}/concoct.09A.%J_%I.log"
#BSUB -e "${CONCOCT_LOGS_E_META}/concoct.09A.%J_%I.err"

# -------------------------
# 09A_2_metaspades_concoct.sh This script runs CONCOCT binning on MEGAHIT assembly
# -------------------------

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX -1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

# Output directory
OUTDIR="${CONCOCT_META}/${NAME}"
mkdir -p $OUTDIR

# Assembly contigs
CONTIGS="${METASPADES_DIR}/${NAME}/contigs.fasta"

# Sorted BAM from alignment step
SORTED_BAM="${ALIGN_METASPADES_DIR}/${NAME}/sorted.bam"

if [[ ! -f $CONTIGS ]]; then
    echo "Error: MEGAHIT assembly not found for ${NAME}"
    exit 1
fi

if [[ ! -f $SORTED_BAM ]]; then
    echo "Error: Sorted BAM not found for ${NAME}"
    exit 1
fi

echo "Processing ${NAME}"

module load apptainer

# Cut contigs into chunks
echo "Starting cut_up_fasta.py"
apptainer exec --bind ${METASPADES_DIR}:${METASPADES_DIR},${CONCOCT_META}:${CONCOCT_META} $CONCOCT \
    cut_up_fasta.py ${CONTIGS} \
    --chunk_size ${CONCOCT_CHUNK_SIZE} \
    --overlap_size 0 \
    --bedfile ${OUTDIR}/contigs_10k.bed \
    --merge_last \
    > ${OUTDIR}/contigs_10k.fa

# Generate coverage table
echo "Starting concoct_coverage_table.py"
apptainer exec --bind ${ALIGN_METASPADES_DIR}:${ALIGN_METASPADES_DIR},${CONCOCT_META}:${CONCOCT_META} $CONCOCT \
    concoct_coverage_table.py ${OUTDIR}/contigs_10k.bed ${SORTED_BAM} > ${OUTDIR}/coverage_table.tsv

# Run CONCOCT
echo "Starting concoct"
apptainer exec --bind ${CONCOCT_META}:${CONCOCT_META} $CONCOCT \
    concoct --threads $JOB9A2_CPUS \
    --composition_file ${OUTDIR}/contigs_10k.fa \
    --coverage_file ${OUTDIR}/coverage_table.tsv \
    -b ${OUTDIR}

# Merge clustering
echo "Starting merge_cutup_clustering.py"
apptainer exec --bind ${CONCOCT_META}:${CONCOCT_META} $CONCOCT \
    merge_cutup_clustering.py ${OUTDIR}/clustering_gt1000.csv > ${OUTDIR}/clustering_merged.csv

# Extract bins
echo "Starting extract_fasta_bins.py"
mkdir -p ${OUTDIR}/fasta_bins
apptainer exec --bind ${METASPADES_DIR}:${METASPADES_DIR},${CONCOCT_META}:${CONCOCT_META} $CONCOCT \
    extract_fasta_bins.py ${CONTIGS} ${OUTDIR}/clustering_merged.csv --output_path ${OUTDIR}/fasta_bins

NUM_BINS=$(ls ${OUTDIR}/fasta_bins/*.fa 2>/dev/null | wc -l)
echo "CONCOCT binning completed: ${NUM_BINS} bins generated for ${NAME}"
date
