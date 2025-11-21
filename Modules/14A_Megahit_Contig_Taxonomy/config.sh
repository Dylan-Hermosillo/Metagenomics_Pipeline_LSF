# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export KRAKEN2=$CONT/quay.io_biocontainers_kraken2:2.1.6--pl5321h077b44d_0.sif
export BRACKEN=$CONT/quay.io_biocontainers_bracken:3.1--h9948957_0.sif
export KRAKENTOOLS=$CONT/quay.io_biocontainers_krakentools:1.2--pyh5e36f6f_0.sif
# Working Dir & Run Scripts
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
export RUN_SCRIPTS=$WORKING_DIR/run_scripts
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# Database paths (update these to your actual database locations)
export DB="/rs1/shares/brc/admin/databases"
export KRAKEN2_DB=$DB/kraken2
# ---- Directory Structure ----
# 14A Contig Taxonomy - MEGAHIT
export CONTIG_TAX_DIR=$WORKING_DIR/14_CONTIG_TAXONOMY
export CONTIG_TAX_DIR_MEGA=$CONTIG_TAX_DIR/14A_contig_taxonomy_megahit
export CONTIG_LOGS_O_MEGA=$CONTIG_TAX_DIR_MEGA/out
export CONTIG_LOGS_E_MEGA=$CONTIG_TAX_DIR_MEGA/err

# --- Job Parameters ---
export JOB14A="14A_megahit_contig_taxonomy"
export QUEUE="shared_memory"

# 14A Contig Taxonomy MEGAHIT
export JOB14A_CPUS=24
export JOB14A_QUEUE="${QUEUE}"
export JOB14A_MEMORY="48GB"
export JOB14A_TIME="12:00"
export KRAKEN2_KMER_SIZE=150  # Kraken2 k-mer size for Bracken

# --- Useful Functions ---

# init dir -- cleans out existing directories or creates them if they don't exist
function init_dir {
    for dir in $*; do
        if [ -d "$dir" ]; then
            rm -rf $dir/*
        else
            mkdir -p "$dir"
        fi
    done
}
# create dir -- creates directories if they don't exist
function create_dir {
    for dir in $*; do
        if [[ ! -d "$dir" ]]; then
          echo "$dir does not exist. Directory created"
          mkdir -p $dir
        fi
    done
}
# line count -- counts number of lines in a file
function lc() {
    wc -l $1 | cut -d ' ' -f 1
}
