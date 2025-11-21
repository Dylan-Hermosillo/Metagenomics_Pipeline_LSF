# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export CHECKM2=$CONT/checkm2.sif
# Working Dir & Run Scripts
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
export RUN_SCRIPTS=$WORKING_DIR/run_scripts
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# Database paths (update these to your actual database locations)
export DB="/rs1/shares/brc/admin/databases"
export CHECKM2_DB=$DB/CheckM2_database/uniref100.KO.1.dmnd
# ---- Directory Structure ----
# 12A CheckM2 - MEGAHIT
export CHECKM2_DIR=$WORKING_DIR/12_CHECKM2
export CHECKM2_MEGA=$CHECKM_DIR/12A_megahit
export CHECKM2_LOGS_O_MEGA=$CHECKM_MEGA/out
export CHECKM2_LOGS_E_MEGA=$CHECKM_MEGA/err

# --- Job Parameters ---
export JOB12A="12A_megahit_checkm2"
export QUEUE="shared_memory"

# 12A CheckM2 MEGAHIT
export JOB12A_CPUS=24
export JOB12A_QUEUE="${QUEUE}"
export JOB12A_MEMORY="32GB"
export JOB12A_TIME="24:00"

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
