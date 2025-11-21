# ---- Housekeeping ----
# Working Dir
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# ---- Directory Structure ----
# 10 Add Bin Numbers
export ADD_BIN_DIR=$BINNING_DIR/10_ADD_BIN_NUMS
export ADD_BIN_LOGS_O=$ADD_BIN_DIR/out
export ADD_BIN_LOGS_E=$ADD_BIN_DIR/err
# --- Job Parameters ---
export JOB10="10_add_bin_nums"
export QUEUE="shared_memory"

# 10 Add Bin Numbers (non-array job) (easy job -- will do both megahit and metaspades here)
export JOB10_CPUS=2
export JOB10_QUEUE="${QUEUE}"
export JOB10_MEMORY="2GB"
export JOB10_TIME="01:00"

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
