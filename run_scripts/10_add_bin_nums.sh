#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${ADD_BIN_LOGS_O}/add_bin_nums.10.%J_%I.log" \
#BSUB -e "${ADD_BIN_LOGS_E}/add_bin_nums.10.%J_%I.err" \

# This script adds bin numbers to contig names and concatenates all bins

# Log info
pwd; hostname; date
source ./config.sh

# Initialize Parameters - ARRAY JOB LOGIC
JOBINDEX=$(($LSB_JOBINDEX - 1))
names=($(cat ${XFILE}))
NAME=${names[${JOBINDEX}]}

echo "Processing ${NAME}"

# Process MEGAHIT bins
BIN_DIR="${CONCOCT_MEGA}/${NAME}/fasta_bins"

if [[ -d "$BIN_DIR" ]]; then
    cd ${CONCOCT_MEGA}
    touch ${NAME}.all_contigs.fna
    
    cd ${BIN_DIR}
    for file in *.fa; do
        if [[ -f "$file" ]]; then
            num=$(echo $file | sed 's/.fa//')
            cat $num.fa | sed -e "s/^>/>${num}_/" >> ${CONCOCT_MEGA}/${NAME}.all_contigs.fna
        fi
    done
    echo "Completed MEGAHIT bins for ${NAME}"
else
    echo "Warning: MEGAHIT bin directory not found for ${NAME}, skipping"
fi

# Process metaSPAdes bins
BIN_DIR="${CONCOCT_META}/${NAME}/fasta_bins"

if [[ -d "$BIN_DIR" ]]; then
    cd ${CONCOCT_META}
    touch ${NAME}.all_contigs.fna
    
    cd ${BIN_DIR}
    for file in *.fa; do
        if [[ -f "$file" ]]; then
            num=$(echo $file | sed 's/.fa//')
            cat $num.fa | sed -e "s/^>/>${num}_/" >> ${CONCOCT_META}/${NAME}.all_contigs.fna
        fi
    done
    echo "Completed metaSPAdes bins for ${NAME}"
else
    echo "Warning: metaSPAdes bin directory not found for ${NAME}, skipping"
fi

date