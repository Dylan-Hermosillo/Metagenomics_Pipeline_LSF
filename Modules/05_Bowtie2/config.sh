# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export BOWTIE2=$CONT/quay.io_biocontainers_bowtie2:2.5.4--he96a11b_6.sif
# Working Dir & Run Scripts
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
export RUN_SCRIPTS=$WORKING_DIR/run_scripts
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# Database paths (update these to your actual database locations)
export DB="/rs1/shares/brc/admin/databases"
export REF_DB=/rs1/shares/brc/admin/databases/hum_db/chm13v2.0_index
# ---- Directory Structure ----
# 05 Bowtie2 Decontamination Outputs
export CONTAM_DIR=$WORKING_DIR/05_BOWTIE2
export CONTAM_LOGS_O=$CONTAM_DIR/out
export CONTAM_LOGS_E=$CONTAM_DIR/err

# --- Job Parameters ---
export JOB5="05_bowtie2"
export QUEUE="shared_memory"

# 05 Bowtie2 Decontamination
export JOB5_CPUS=16
export JOB5_QUEUE="${QUEUE}"
export JOB5_MEMORY="8GB"
export JOB5_TIME="10:00"

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
