# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export QUAST=$CONT/quay.io_biocontainers_quast:5.2.0--py310pl5321hc8f18ef_2.sif
# Working Dir & Run Scripts
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
export RUN_SCRIPTS=$WORKING_DIR/run_scripts
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# ---- Directory Structure ----
# 11B QUAST - metaSPAdes
export QUAST_DIR=$WORKING_DIR/11_QUAST
export QUAST_META=$QUAST_DIR/11B_metaspades 
export QUAST_LOGS_O_META=$QUAST_META/out
export QUAST_LOGS_E_META=$QUAST_META/err

# --- Job Parameters ---
export JOB11B="11B_metaspades_quast"
export QUEUE="shared_memory"

# 11B QUAST metaSPAdes
export JOB11B_CPUS=8
export JOB11B_QUEUE="${QUEUE}"
export JOB11B_MEMORY="16GB"
export JOB11B_TIME="12:00"

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
