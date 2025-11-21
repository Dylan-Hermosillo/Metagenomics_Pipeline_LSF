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
# 13 Read Taxonomy
export READ_TAX_DIR=$WORKING_DIR/13_READ_TAXONOMY
export READ_TAX_LOGS_O=$READ_TAX_DIR/out
export READ_TAX_LOGS_E=$READ_TAX_DIR/err

# --- Job Parameters ---
export JOB13="13_read_taxonomy"
export QUEUE="shared_memory"

# 13 Read Taxonomy
export JOB13_CPUS=24
export JOB13_QUEUE="${QUEUE}"
export JOB13_MEMORY="48GB"
export JOB13_TIME="12:00"
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
