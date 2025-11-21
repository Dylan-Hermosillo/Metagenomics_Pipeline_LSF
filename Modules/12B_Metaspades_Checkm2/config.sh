# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export CHECKM2=$CONT/checkm2.sif
# Working Dir
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# Database paths (update these to your actual database locations)
export DB="/rs1/shares/brc/admin/databases"
export CHECKM2_DB=$DB/CheckM2_database/uniref100.KO.1.dmnd
# ---- Directory Structure ----
# 12B CheckM2 - metaSPAdes
export CHECKM2_DIR=$WORKING_DIR/12_CHECKM2
export CHECKM2_META=$CHECKM_DIR/12B_metaspades
export CHECKM2_LOGS_O_META=$CHECKM_META/out
export CHECKM2_LOGS_E_META=$CHECKM_META/err
# --- Job Parameters ---
export JOB12B="12B_metaspades_checkm2"
export QUEUE="shared_memory"

# 12B CheckM2 metaSPAdes
export JOB12B_CPUS=24
export JOB12B_QUEUE="${QUEUE}"
export JOB12B_MEMORY="32GB"
export JOB12B_TIME="24:00"
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
