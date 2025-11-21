# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export CONCOCT=$CONT/quay.io_biocontainers_concoct:1.1.0--py38h7be5676_2.sif
# Working Dir
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# ---- Directory Structure ----
# 09A CONCOCT Binning - MEGAHIT
export BINNING_DIR=$WORKING_DIR/09_BINNING
export CONCOCT_MEGA=$BINNING_DIR/09A_concoct_megahit
export CONCOCT_LOGS_O_MEGA=$CONCOCT_MEGA/out
export CONCOCT_LOGS_E_MEGA=$CONCOCT_MEGA/err

# --- Job Parameters ---
export JOB9A="09A_megahit_concoct"
export QUEUE="shared_memory"

# 09A CONCOCT/BWA Binning - MEGAHIT
export JOB9A_CPUS=24
export JOB9A_QUEUE="${QUEUE}"
export JOB9A_MEMORY="32GB"
export JOB9A_TIME="12:00"
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
