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
# 08B Alignment - metaSPAdes
export ALIGN_DIR=$WORKING_DIR/08_ALIGNMENT
export ALIGN_METASPADES_DIR=$ALIGN_DIR/08B_metaspades
export ALIGN_METASPADES_LOGS_O=$ALIGN_METASPADES_DIR/out
export ALIGN_METASPADES_LOGS_E=$ALIGN_METASPADES_DIR/err

# --- Job Parameters ---
export JOB8B="08B_metaspades_alignment"
export QUEUE="shared_memory"

# 08B Align metaSPAdes
export JOB8B_CPUS=8
export JOB8B_QUEUE="${QUEUE}"
export JOB8B_MEMORY="10GB"
export JOB8B_TIME="10:00"
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
