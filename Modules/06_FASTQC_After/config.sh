# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export FASTQC=$CONT/quay.io_biocontainers_fastqc:0.12.1--hdfd78af_0.sif
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
# Working Dir
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# ---- Directory Structure ----
# 06 FastQC After Trim Outputs
export FASTQC_AFTER=$WORKING_DIR/06_FASTQC_AFTER
export FASTQC_AFTER_LOGS_O=$FASTQC_AFTER/out
export FASTQC_AFTER_LOGS_E=$FASTQC_AFTER/err
export FASTQC_A_HTML=$FASTQC_AFTER/htmls

# --- Job Parameters ---
export JOB6="06_fastqc_after"
export QUEUE="shared_memory"

# 06 FastQC After Trim
export JOB6_CPUS=1
export JOB6_QUEUE="${QUEUE}"
export JOB6_MEMORY="1GB"
export JOB6_TIME="02:00"
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
