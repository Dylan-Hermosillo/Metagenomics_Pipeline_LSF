# ---- Housekeeping ----

# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export SRA_TOOLKIT=$CONT/quay.io_biocontainers_sra-tools:3.2.1--h4304569_1.sif
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
# Working Dir
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# ---- Directory Structure ----
# 01 Input/Output directories; for the wrapper generation
export WRAP_OUT=$WORKING_DIR/01_WRAPPER_GEN
export WRAP_SCRIPTS=$WORKING_DIR/01_WRAPPER_GEN/scripts # wrapper scripts to be aggregated
export WRAP_LOGS_O=$WRAP_OUT/out
export WRAP_LOGS_E=$WRAP_OUT/err
# 02 Data Pull Parallel
export DATASET_LIST=$WORKING_DIR/test_data.txt
export READS_DIR=$WORKING_DIR/02_SRA_TOOLKIT
export SRA_LOGS_O=$READS_DIR/out
export SRA_LOGS_E=$READS_DIR/err

# --- Job Parameters ---
export JOB1="01_wrapper_gen"
export QUEUE="shared_memory"
export JOB2="02_SRA_pull"
export QUEUE="shared_memory"

# 01 Wrapper Gen
export JOB1_CPUS=1
export JOB1_QUEUE="${QUEUE}"
export JOB1_MEMORY="1GB"
export JOB1_TIME="0:05"
export CHUNK_SIZE=50
# 02 SRA Pull
export JOB2_CPUS=6

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
