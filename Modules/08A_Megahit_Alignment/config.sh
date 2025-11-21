# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export BWA=$CONT/quay.io_biocontainers_bwa:0.7.17--h5bf99c6_8.sif
export SAMTOOLS=$CONT/staphb_samtools:1.21.sif
# Working Dir & Run Scripts
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
export RUN_SCRIPTS=$WORKING_DIR/run_scripts
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# ---- Directory Structure ----
# 08A Alignment - MEGAHIT
export ALIGN_DIR=$WORKING_DIR/08_ALIGNMENT
export ALIGN_MEGAHIT_DIR=$ALIGN_DIR/08A_megahit
export ALIGN_MEGAHIT_LOGS_O=$ALIGN_MEGAHIT_DIR/out
export ALIGN_MEGAHIT_LOGS_E=$ALIGN_MEGAHIT_DIR/err

# --- Job Parameters ---
export JOB8A="08A_megahit_alignment"
export QUEUE="shared_memory"

# 08A Align MEGAHIT
export JOB8A_CPUS=8
export JOB8A_QUEUE="${QUEUE}"
export JOB8A_MEMORY="10GB"
export JOB8A_TIME="10:00"

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
