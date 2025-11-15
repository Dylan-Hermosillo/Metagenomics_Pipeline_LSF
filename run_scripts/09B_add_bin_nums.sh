#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${CONCOCT_LOGS_O}/add_bin_nums.09B.%J.log"
#BSUB -e "${CONCOCT_LOGS_E}/add_bin_nums.09B.%J.err"

# This script adds bin numbers to contig names and concatenates all bins

# Log info
pwd; hostname; date
source ./config.sh

# Read all sample names
names=($(cat ${XFILE}))

# Do megahit assemblies first
cd $CONCOCT_MEGA
echo "Starting bin number addition for MEGAHIT assemblies"
for NAME in "${names[@]}"; do
    echo "Processing ${NAME}"
    
    BIN_DIR="${CONCOCT_MEGA}/${NAME}/fasta_bins"
    
    if [[ ! -d "$BIN_DIR" ]]; then
        echo "Warning: Bin directory not found for ${NAME}, skipping"
        continue
    fi
    
    # Create concatenated file
    touch ${NAME}.all_contigs.fna
    
    cd ${BIN_DIR}
    
    # Process each bin
    for file in *.fa; do
        if [[ -f "$file" ]]; then
            num=$(echo $file | sed 's/.fa//')
            cat $num.fa | sed -e "s/^>/>${num}_/" >> ${CONCOCT_MEGA}/${NAME}.all_contigs.fna
        fi
    done
    
    cd $CONCOCT_MEGA
    
    echo "Completed ${NAME}"
done

echo "Bin number addition completed to MEGAHIT assemblies"
date

# Do metaspades assemblies next

cd $CONCOCT_META
echo "Starting bin number addition for metaSPAdes assemblies"
for NAME in "${names[@]}"; do
    echo "Processing ${NAME}"
    
    BIN_DIR="${CONCOCT_META}/${NAME}/fasta_bins"
    
    if [[ ! -d "$BIN_DIR" ]]; then
        echo "Warning: Bin directory not found for ${NAME}, skipping"
        continue
    fi
    
    # Create concatenated file
    touch ${NAME}.all_contigs.fna
    
    cd ${BIN_DIR}
    
    # Process each bin
    for file in *.fa; do
        if [[ -f "$file" ]]; then
            num=$(echo $file | sed 's/.fa//')
            cat $num.fa | sed -e "s/^>/>${num}_/" >> ${CONCOCT_META}/${NAME}.all_contigs.fna
        fi
    done
    
    cd $CONCOCT_META
    
    echo "Completed ${NAME}"
done

echo "Bin number addition completed to metaSPAdes assemblies"
date