# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export SPADES=$CONT/quay.io_biocontainers_spades:4.2.0--h8d6e82b_2.sif
# Working Dir
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# ---- Directory Structure ----
# 07B Assembly Outputs - metaSPAdes
export ASSEM_DIR=$WORKING_DIR/07_ASSEMBLY
export METASPADES_DIR=$ASSEM_DIR/07B_metaspades_assembly
export METASPADES_LOGS_O=$METASPADES_DIR/out
export METASPADES_LOGS_E=$METASPADES_DIR/err

# --- Job Parameters ---
export JOB7B="07B_metaspades_assembly"
export QUEUE="shared_memory"

# 07B metaSPAdes Assembly
export JOB7B_CPUS=20
export JOB7B_QUEUE="${QUEUE}"
export JOB7B_MEMORY="128GB"
export JOB7B_MEMORY_GB=128  # metaSPAdes uses GB value
export JOB7B_TIME="24:00"

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
