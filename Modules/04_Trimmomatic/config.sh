# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export TRIMMOMATIC=$CONT/quay.io_biocontainers_trimmomatic:0.40--hdfd78af_0.sif
# Working Dir
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
export RUN_SCRIPTS=$WORKING_DIR/run_scripts
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# Database paths (update these to your actual database locations)
export DB="/rs1/shares/brc/admin/databases"
export ADAPTERS=/rs1/shares/brc/admin/databases/adapters/TruSeq3-PE-2.fa
# ---- Directory Structure ----
# 04 Trimmomatic Outputs
export TRIM_DIR=$WORKING_DIR/04_TRIMMOMATIC
export TRIMMED=$TRIM_DIR/trimmed_reads
export UNPAIRED=$TRIM_DIR/unpaired_reads
export TRIM_LOGS_O=$TRIM_DIR/out
export TRIM_LOGS_E=$TRIM_DIR/err
export TRIM_ILLUMINACLIP="2:30:10"  # seed mismatches:palindrome threshold:simple threshold
export TRIM_SLIDINGWINDOW="4:20"    # window size:quality threshold
export TRIM_MINLEN="100"            # minimum read length
export TRIM_HEADCROP="10"           # bases to remove from start
# --- Job Parameters ---
export JOB4="04_trimmomatic"
export QUEUE="shared_memory"

# 04 Trimmomatic
export JOB4_CPUS=4
export JOB4_QUEUE="${QUEUE}"
export JOB4_MEMORY="2GB"
export JOB4_TIME="04:30"

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
