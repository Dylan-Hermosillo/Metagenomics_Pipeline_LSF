# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export FASTQC=$CONT/quay.io_biocontainers_fastqc:0.12.1--hdfd78af_0.sif
# Working Dir & Run Scripts
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
export RUN_SCRIPTS=$WORKING_DIR/run_scripts
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# ---- Directory Structure ----
# 03 FastQC Before Trim Outputs
export FASTQC_BEFORE=$WORKING_DIR/03_FASTQC_BEFORE
export FASTQC_LOGS_O=$FASTQC_BEFORE/out
export FASTQC_LOGS_E=$FASTQC_BEFORE/err
export FASTQC_B_HTML=$FASTQC_BEFORE/htmls
# --- Job Parameters ---
export JOB3="03_fastqc_before"
export QUEUE="shared_memory"
# 03 FastQC Before Trim
export JOB3_CPUS=1
export JOB3_QUEUE="${QUEUE}"
export JOB3_MEMORY="1GB"
export JOB3_TIME="02:00"

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
