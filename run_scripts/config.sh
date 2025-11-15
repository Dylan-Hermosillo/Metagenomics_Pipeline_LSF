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

# 1) Change 00 WORKING_DIR
# 2) Define where RUN_SCRIPTS are located
# The rest will automatically create the file structure without having to edit anything
# Here I separate my working dir from the pipeline directory, for example.

# 01 Input/Output directories; for the wrapper generation
export WRAP_OUT="$WORKING_DIR/01_WRAPPER_GEN"
export WRAP_SCRIPTS="$WORKING_DIR/01_WRAPPER_GEN/scripts" # wrapper scripts to be aggregated
export WRAP_LOGS_O="$WRAP_OUT/out"
export WRAP_LOGS_E="$WRAP_OUT/err"
# 02 Data Pull Parallel
export DATASET_LIST="$WORKING_DIR/test_data.txt"
export READS_DIR=$WORKING_DIR/02_SRA_TOOLKIT
export SRA_LOGS_O=$READS_DIR/out
export SRA_LOGS_E=$READS_DIR/err
# 03 FastQC Before Trim Outputs
export FASTQC_BEFORE=$WORKING_DIR/03_FASTQC_BEFORE
export FASTQC_LOGS_O=$FASTQC_BEFORE/out
export FASTQC_LOGS_E=$FASTQC_BEFORE/err
export FASTQC_B_HTML=$FASTQC_BEFORE/htmls
# 04 Trimmomatic Outputs
export TRIM_DIR=$WORKING_DIR/04_TRIMMOMATIC
export TRIMMED=$TRIM_DIR/trimmed_reads
export UNPAIRED=$TRIM_DIR/unpaired_reads
export TRIM_LOGS_O=$TRIM_DIR/out
export TRIM_LOGS_E=$TRIM_DIR/err
# 05 Bowtie2 Decontamination Outputs
export CONTAM_DIR=$WORKING_DIR/05_BOWTIE2
export CONTAM_LOGS_O=$CONTAM_DIR/out
export CONTAM_LOGS_E=$CONTAM_DIR/err
# 06 FastQC After Trim Outputs
export FASTQC_AFTER=$WORKING_DIR/06_FASTQC_AFTER
export FASTQC_AFTER_LOGS_O=$FASTQC_AFTER/out
export FASTQC_AFTER_LOGS_E=$FASTQC_AFTER/err
export FASTQC_A_HTML=$FASTQC_AFTER/htmls
# 07 Assembly Outputs
export ASSEM_DIR=$WORKING_DIR/07_ASSEMBLY
export MEGAHIT_DIR=$ASSEM_DIR/07A_megahit_assembly # MEGAHIT
export MEGAHIT_LOGS_O=$MEGAHIT_DIR/out
export MEGAHIT_LOGS_E=$MEGAHIT_DIR/err
export METASPADES_DIR=$ASSEM_DIR/07B_metaspades_assembly # metaSPAdes
export METASPADES_LOGS_O=$METASPADES_DIR/out
export METASPADES_LOGS_E=$METASPADES_DIR/err
# 08A Alignment - MEGAHIT
export ALIGN_DIR=$WORKING_DIR/08_ALIGNMENT
export ALIGN_MEGAHIT_DIR=$ALIGN_DIR/08A_megahit
export ALIGN_MEGAHIT_LOGS_O=$ALIGN_MEGAHIT_DIR/out
export ALIGN_MEGAHIT_LOGS_E=$ALIGN_MEGAHIT_DIR/err
# 08B Alignment - metaSPAdes
export ALIGN_METASPADES_DIR=$ALIGN_DIR/08B_metaspades
export ALIGN_METASPADES_LOGS_O=$ALIGN_METASPADES_DIR/out
export ALIGN_METASPADES_LOGS_E=$ALIGN_METASPADES_DIR/err
# 09A CONCOCT Binning
export BINNING_DIR=$WORKING_DIR/09_BINNING
export CONCOCT_MEGA=$BINNING_DIR/09A_concoct_megahit # MEGAHIT
export CONCOCT_LOGS_O_MEGA=$CONCOCT_MEGA/out
export CONCOCT_LOGS_E_MEGA=$CONCOCT_MEGA/err
export CONCOCT_META=$BINNING_DIR/09A_concoct_metaspades # metaSPAdes
export CONCOCT_LOGS_O_META=$CONCOCT_META/out
export CONCOCT_LOGS_E_META=$CONCOCT_META/err
# 09C QUAST
export QUAST_DIR=$BINNING_DIR/09C_quast
export QUAST_MEGA=$QUAST_DIR/09C_megahit # MEGAHIT
export QUAST_LOGS_O_MEGA=$QUAST_MEGA/out
export QUAST_LOGS_E_MEGA=$QUAST_MEGA/err
export QUAST_META=$QUAST_DIR/09C_metaspades # metaSPAdes
export QUAST_LOGS_O_META=$QUAST_META/out
export QUAST_LOGS_E_META=$QUAST_META/err
# 09D CheckM2
export CHECKM_DIR=$BINNING_DIR/09D_checkm
export CHECKM_MEGA=$CHECKM_DIR/09D_megahit # MEGAHIT
export CHECKM_LOGS_O_MEGA=$CHECKM_MEGA/out
export CHECKM_LOGS_E_MEGA=$CHECKM_MEGA/err
export CHECKM_META=$CHECKM_DIR/09D_metaspades # metaSPAdes
export CHECKM_LOGS_O_META=$CHECKM_META/out
export CHECKM_LOGS_E_META=$CHECKM_META/err
# 10A Read Taxonomy
export TAXONOMY_DIR=$WORKING_DIR/10_TAXONOMY
export READ_TAX_DIR=$TAXONOMY_DIR/10A_read_taxonomy
export READ_TAX_LOGS_O=$READ_TAX_DIR/out
export READ_TAX_LOGS_E=$READ_TAX_DIR/err
# 10B Contig Taxonomy
export CONTIG_TAX_DIR=$TAXONOMY_DIR/10B_contig_taxonomy
export CONTIG_TAX_LOGS_O=$CONTIG_TAX_DIR/out
export CONTIG_TAX_LOGS_E=$CONTIG_TAX_DIR/err

# ---- End Directory Structure ----

# --- Job Parameters ---
# List of Jobs to run
export JOB1="01_wrapper_gen"
export JOB2="02_SRA_pull"
export JOB3="03_fastqc_before"
export JOB4="04_trimmomatic"
export JOB5="05_bowtie2"
export JOB6="06_fastqc_after"
export JOB7A="07A_megahit"
export JOB7B="07B_metaspades"
export JOB8A="08A_align_megahit"
export JOB8B="08B_align_metaspades"
export JOB9A1="09A_1_megahit_concoct"
export JOB9A2="09A_2_metaspades_concoct"
export JOB9B="09B_add_bin_nums"
export JOB9C1="09C_1_megahit_quast"
export JOB9C2="09C_2_metaspades_quast"
export JOB9D1="09D_1_megahit_checkm"
export JOB9D1="09D_2_metaspades_checkm"
export JOB10A="10A_read_taxonomy"
export JOB10B="10B_contig_taxonomy"
export QUEUE="shared_memory"
# 01 Wrapper Gen
export JOB1_CPUS=6
export JOB1_QUEUE="${QUEUE}"
export JOB1_MEMORY="1000"
export JOB1_TIME="0:05"
export CHUNK_SIZE=50
# 02 SRA Pull
export JOB2_CPUS=6
# 03 FastQC Before Trim
export JOB3_CPUS=4
export JOB3_QUEUE="${QUEUE}"
export JOB3_MEMORY="4000"
export JOB3_TIME="01:00"
# 04 Trimmomatic
export JOB4_CPUS=8
export JOB4_QUEUE="${QUEUE}"
export JOB4_MEMORY="4000"
export JOB4_TIME="02:00"
# 05 Bowtie2 Decontamination
export JOB5_CPUS=16
export JOB5_QUEUE="${QUEUE}"
export JOB5_MEMORY="64000"
export JOB5_TIME="06:00"
# 06 FastQC After Trim
export JOB6_CPUS=4
export JOB6_QUEUE="${QUEUE}"
export JOB6_MEMORY="4000"
export JOB6_TIME="01:00"
# 07A MEGAHIT Assembly
export JOB7A_CPUS=32
export JOB7A_QUEUE="${QUEUE}"
export JOB7A_MEMORY="128000"
export JOB7A_MEMORY_GB=0.9  # MEGAHIT uses ratio (0.0-1.0) or exact value
export JOB7A_TIME="24:00"
# 07B metaSPAdes Assembly
export JOB7B_CPUS=32
export JOB7B_QUEUE="${QUEUE}"
export JOB7B_MEMORY="128000"
export JOB7B_MEMORY_GB=128  # metaSPAdes uses GB value
export JOB7B_TIME="48:00"
# 08A Align MEGAHIT
export JOB8A_CPUS=16
export JOB8A_QUEUE="${QUEUE}"
export JOB8A_MEMORY="32000"
export JOB8A_TIME="08:00"
# 08B Align metaSPAdes
export JOB8B_CPUS=16
export JOB8B_QUEUE="${QUEUE}"
export JOB8B_MEMORY="32000"
export JOB8B_TIME="08:00"
# 09A1 CONCOCT/BWA Binning - MEGAHIT
export JOB9A1_CPUS=24
export JOB9A1_QUEUE="${QUEUE}"
export JOB9A1_MEMORY="64000"
export JOB9A1_TIME="24:00"
# 09A2 CONCOCT/BWA Binning - metaspades
export JOB9A2_CPUS=24
export JOB9A2_QUEUE="${QUEUE}"
export JOB9A2_MEMORY="64000"
export JOB9A2_TIME="24:00"
export CONCOCT_CHUNK_SIZE=10000
# 09B Add Bin Numbers (non-array job) (easy job -- will do both megahit and metaspades here)
export JOB9B_CPUS=1
export JOB9B_QUEUE="${QUEUE}"
export JOB9B_MEMORY="4000"
export JOB9B_TIME="01:00"
# 09C1 QUAST MEGAHIT
export JOB9C1_CPUS=24
export JOB9C1_QUEUE="${QUEUE}"
export JOB9C1_MEMORY="16000"
export JOB9C1_TIME="04:00"
# 09C2 QUAST metaSPAdes
export JOB9C2_CPUS=24
export JOB9C2_QUEUE="${QUEUE}"
export JOB9C2_MEMORY="16000"
export JOB9C2_TIME="04:00"
# 09D CheckM2 MEGAHIT
export JOB9D1_CPUS=24
export JOB9D1_QUEUE="${QUEUE}"
export JOB9D1_MEMORY="64000"
export JOB9D1_TIME="12:00"
# 09D CheckM2 metaSPAdes
export JOB9D2_CPUS=24
export JOB9D2_QUEUE="${QUEUE}"
export JOB9D2_MEMORY="64000"
export JOB9D2_TIME="12:00"
# 10A Read Taxonomy
export JOB10A_CPUS=24
export JOB10A_QUEUE="${QUEUE}"
export JOB10A_MEMORY="64000"
export JOB10A_TIME="08:00"
export KRAKEN2_KMER_SIZE=150  # Kraken2 k-mer size for Bracken
# 10B Contig Taxonomy
export JOB10B_CPUS=24
export JOB10B_QUEUE="${QUEUE}"
export JOB10B_MEMORY="64000"
export JOB10B_TIME="08:00"

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
