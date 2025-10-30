# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export SRA_TOOLKIT=$CONT/quay.io_biocontainers_sra-tools:3.2.1--h4304569_1.sif
export FASTQC=$CONT/quay.io_biocontainers_fastqc:0.12.1--hdfd78af_0.sif
export TRIMMOMATIC=$CONT/quay.io_biocontainers_trimmomatic:0.40--hdfd78af_0.sif
export BOWTIE2=$CONT/quay.io_biocontainers_bowtie2:2.5.4--he96a11b_6.sif
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/share/ivirus/dhermos/Metagenomics_Pipeline_LSF/01_Pull_Check_Trim_Decontam/test_data/test_data.txt
# Reference Genome for Decontamination
export REF_DB=/rs1/shares/brc/admin/databases/hum_db
# Adapter File for Trimmomatic
export ADAPTERS=/rs1/shares/brc/admin/databases/adapters/TruSeq3-PE-2.fa

# ---- Directory Structure ----
# 00 Working Dir & Run Scripts
export WORKING_DIR=/share/ivirus/dhermos/metagenome_test # where I want all the output to go
export RUN_SCRIPTS=/share/ivirus/dhermos/Metagenomics_Pipeline_LSF/01_Pull_Check_Trim_Decontam/run_scripts # where the pipeline & run scripts are stored
# 01 Reads Dir (SRA Toolkit output)
export READS_DIR=$WORKING_DIR/01_SRA_TOOLKIT
export SRA_LOGS_O=$READS_DIR/out/
export SRA_LOGS_E=$READS_DIR/err/
# 02 FastQC Before Trim Outputs
export FASTQC_BEFORE=$WORKING_DIR/02_FASTQC_BEFORE
export FASTQC_LOGS_O=$FASTQC_BEFORE/out/
export FASTQC_LOGS_E=$FASTQC_BEFORE/err/
# 03 Trimmomatic Outputs
export TRIM_DIR=$WORKING_DIR/03_TRIMMOMATIC
export TRIMMED=$TRIM_DIR/trimmed_reads
export UNPAIRED=$TRIM_DIR/unpaired_reads
export TRIM_LOGS_O=$TRIM_DIR/out/
export TRIM_LOGS_E=$TRIM_DIR/err/
# 04 Bowtie2 Decontamination Outputs
export CONTAM_DIR=$WORKING_DIR/05_BOWTIE2
export CONTAM_LOGS_O=$CONTAM_DIR/out/
export CONTAM_LOGS_E=$CONTAM_DIR/err/
# 05 FastQC After Trim Outputs
export FASTQC_AFTER=$WORKING_DIR/04_FASTQC_AFTER
export FASTQC_AFTER_LOGS_O=$FASTQC_AFTER/out/
export FASTQC_AFTER_LOGS_E=$FASTQC_AFTER/err/

# ---- End Directory Structure ----

# --- Job Parameters ---
# List of Jobs to run
export JOB1="01A_sra_prefetch"
export JOB2="01B_sra_dump"
export JOB3="02_fastqc_before"
export JOB4="03_trimmomatic"
export JOB5="04_bowtie2"
export JOB6="05_fastqc_after"
# 01 SRA Prefetch
export JOB1_CPUS=1
export JOB1_QUEUE="shared_memory"
export JOB1_MEMORY="4G"
export JOB1_TIME="00:30"
# 01B SRA Dump
export JOB2_CPUS=8
export JOB2_QUEUE="shared_memory"
export JOB2_MEMORY="16G"
export JOB2_TIME="06:00"
# 02 FastQC Before Trim
export JOB3_CPUS=4
export JOB3_QUEUE="shared_memory"
export JOB3_MEMORY="4G"
export JOB3_TIME="01:00"
# 03 Trimmomatic
export JOB4_CPUS=8
export JOB4_QUEUE="shared_memory"
export JOB4_MEMORY="16G"
export JOB4_TIME="02:00"
# 04 Bowtie2 Decontamination
export JOB5_CPUS=16
export JOB5_QUEUE="shared_memory"
export JOB5_MEMORY="32G"
export JOB5_TIME="06:00"
# 05 FastQC After Trim
export JOB6_CPUS=4
export JOB6_QUEUE="shared_memory"
export JOB6_MEMORY="4G"
export JOB6_TIME="01:00"

# Useful Functions

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
# --------------------------------------------------
function create_dir {
    for dir in $*; do
        if [[ ! -d "$dir" ]]; then
          echo "$dir does not exist. Directory created"
          mkdir -p $dir
        fi
    done
}
# line count -- counts number of lines in a file
# --------------------------------------------------
function lc() {
    wc -l $1 | cut -d ' ' -f 1
}