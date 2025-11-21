# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export CONCOCT=$CONT/quay.io_biocontainers_concoct:1.1.0--py38h7be5676_2.sif
# Working Dir & Run Scripts
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
export RUN_SCRIPTS=$WORKING_DIR/run_scripts
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# ---- Directory Structure ----
# 09B CONCOCT Binning - metaSPAdes
export CONCOCT_META=$BINNING_DIR/09A_concoct_metaspades
export CONCOCT_LOGS_O_META=$CONCOCT_META/out
export CONCOCT_LOGS_E_META=$CONCOCT_META/err

# --- Job Parameters ---
export JOB9B="09B_metaspades_concoct"
export QUEUE="shared_memory"

# 09B CONCOCT/BWA Binning - metaspades
export JOB9B_CPUS=24
export JOB9B_QUEUE="${QUEUE}"
export JOB9B_MEMORY="32GB"
export JOB9B_TIME="12:00"
export CONCOCT_CHUNK_SIZE=10000
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
