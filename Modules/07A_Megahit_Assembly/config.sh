# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export MEGAHIT=$CONT/quay.io_biocontainers_megahit:1.2.9--haf24da9_8.sif
# Working Dir
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# ---- Directory Structure ----
# 07A Assembly Outputs - MEGAHIT
export ASSEM_DIR=$WORKING_DIR/07_ASSEMBLY
export MEGAHIT_DIR=$ASSEM_DIR/07A_megahit_assembly
export MEGAHIT_LOGS_O=$MEGAHIT_DIR/out
export MEGAHIT_LOGS_E=$MEGAHIT_DIR/err

# --- Job Parameters ---
export JOB7A="07A_megahit_assembly"
export QUEUE="shared_memory"

# 07A MEGAHIT Assembly
export JOB7A_CPUS=16
export JOB7A_QUEUE="${QUEUE}"
export JOB7A_MEMORY="16GB"
export JOB7A_MEMORY_GB=0.9  # MEGAHIT uses ratio (0.0-1.0) or exact value
export JOB7A_TIME="06:00"

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
