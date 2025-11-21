# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export SRA_TOOLKIT=$CONT/quay.io_biocontainers_sra-tools:3.2.1--h4304569_1.sif
export FASTQC=$CONT/quay.io_biocontainers_fastqc:0.12.1--hdfd78af_0.sif
export TRIMMOMATIC=$CONT/quay.io_biocontainers_trimmomatic:0.40--hdfd78af_0.sif
export BOWTIE2=$CONT/quay.io_biocontainers_bowtie2:2.5.4--he96a11b_6.sif
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export MEGAHIT=$CONT/quay.io_biocontainers_megahit:1.2.9--haf24da9_8.sif
export SPADES=$CONT/quay.io_biocontainers_spades:4.2.0--h8d6e82b_2.sif
export BWA=$CONT/quay.io_biocontainers_bwa:0.7.17--h5bf99c6_8.sif
export SAMTOOLS=$CONT/staphb_samtools:1.21.sif
export CONCOCT=$CONT/quay.io_biocontainers_concoct:1.1.0--py38h7be5676_2.sif
export QUAST=$CONT/quay.io_biocontainers_quast:5.2.0--py310pl5321hc8f18ef_2.sif
export CHECKM=$CONT/checkm2.sif
export KRAKEN2=$CONT/quay.io_biocontainers_kraken2:2.1.6--pl5321h077b44d_0.sif
export BRACKEN=$CONT/quay.io_biocontainers_bracken:3.1--h9948957_0.sif
export KRAKENTOOLS=$CONT/quay.io_biocontainers_krakentools:1.2--pyh5e36f6f_0.sif
# Working Dir & Run Scripts
export WORKING_DIR=/share/ivirus/dhermos/pipeline_test # where I want all the output to go
export RUN_SCRIPTS=$WORKING_DIR/run_scripts
# Files -- change this txt to a list of your SRR/ERR id's
export XFILE=$WORKING_DIR/test_data/test_data.txt
# Database paths (update these to your actual database locations)
export DB="/rs1/shares/brc/admin/databases"
export REF_DB=/rs1/shares/brc/admin/databases/hum_db/chm13v2.0_index
export ADAPTERS=/rs1/shares/brc/admin/databases/adapters/TruSeq3-PE-2.fa
export CHECKM2_DB=$DB/CheckM2_database/uniref100.KO.1.dmnd
export KRAKEN2_DB=$DB/kraken2
# ---- Directory Structure ----
# 01 Input/Output directories; for the wrapper generation
export WRAP_OUT=$WORKING_DIR/01_WRAPPER_GEN
export WRAP_SCRIPTS=$WORKING_DIR/01_WRAPPER_GEN/scripts # wrapper scripts to be aggregated
export WRAP_LOGS_O=$WRAP_OUT/out
export WRAP_LOGS_E=$WRAP_OUT/err

# --- Job Parameters ---
export JOB1="01_wrapper_gen"
export QUEUE="shared_memory"

# 01 Wrapper Gen
export JOB1_CPUS=1
export JOB1_QUEUE="${QUEUE}"
export JOB1_MEMORY="1GB"
export JOB1_TIME="0:05"
export CHUNK_SIZE=50

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
