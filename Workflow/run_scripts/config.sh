# ---- Housekeeping ----
# Containers
export CONT=/rs1/shares/brc/admin/containers/images # main image directory
export APPT=/usr/local/apps/apptainer/1.4.2-1/bin/apptainer
export SRA_TOOLKIT=$CONT/quay.io_biocontainers_sra-tools:3.2.1--h4304569_1.sif
export FASTQC=$CONT/quay.io_biocontainers_fastqc:0.12.1--hdfd78af_0.sif
export TRIMMOMATIC=$CONT/quay.io_biocontainers_trimmomatic:0.40--hdfd78af_0.sif
export BOWTIE2=$CONT/quay.io_biocontainers_bowtie2:2.5.4--he96a11b_6.sif
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
export WRAP_OUT=$WORKING_DIR/01_WRAPPER_GEN
export WRAP_SCRIPTS=$WORKING_DIR/01_WRAPPER_GEN/scripts # wrapper scripts to be aggregated
export WRAP_LOGS_O=$WRAP_OUT/out
export WRAP_LOGS_E=$WRAP_OUT/err
# 02 Data Pull Parallel
export DATASET_LIST=$WORKING_DIR/test_data.txt
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
# 07A Assembly Outputs - MEGAHIT
export ASSEM_DIR=$WORKING_DIR/07_ASSEMBLY
export MEGAHIT_DIR=$ASSEM_DIR/07A_megahit_assembly
export MEGAHIT_LOGS_O=$MEGAHIT_DIR/out
export MEGAHIT_LOGS_E=$MEGAHIT_DIR/err
# 07B Assembly Outputs - metaSPAdes
export METASPADES_DIR=$ASSEM_DIR/07B_metaspades_assembly
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
# 09A CONCOCT Binning - MEGAHIT
export BINNING_DIR=$WORKING_DIR/09_BINNING
export CONCOCT_MEGA=$BINNING_DIR/09A_concoct_megahit
export CONCOCT_LOGS_O_MEGA=$CONCOCT_MEGA/out
export CONCOCT_LOGS_E_MEGA=$CONCOCT_MEGA/err
# 09B CONCOCT Binning - metaSPAdes
export CONCOCT_META=$BINNING_DIR/09A_concoct_metaspades
export CONCOCT_LOGS_O_META=$CONCOCT_META/out
export CONCOCT_LOGS_E_META=$CONCOCT_META/err
# 10 Add Bin Numbers
export ADD_BIN_DIR=$BINNING_DIR/10_ADD_BIN_NUMS
export ADD_BIN_LOGS_O=$ADD_BIN_DIR/out
export ADD_BIN_LOGS_E=$ADD_BIN_DIR/err
# 11A QUAST - MEGAHIT
export QUAST_DIR=$WORKING_DIR/11_QUAST
export QUAST_MEGA=$QUAST_DIR/11A_megahit
export QUAST_LOGS_O_MEGA=$QUAST_MEGA/out
export QUAST_LOGS_E_MEGA=$QUAST_MEGA/err
# 11B QUAST - metaSPAdes
export QUAST_META=$QUAST_DIR/11B_metaspades 
export QUAST_LOGS_O_META=$QUAST_META/out
export QUAST_LOGS_E_META=$QUAST_META/err
# 12A CheckM2 - MEGAHIT
export CHECKM2_DIR=$WORKING_DIR/12_CHECKM2
export CHECKM2_MEGA=$CHECKM2_DIR/12A_megahit
export CHECKM2_LOGS_O_MEGA=$CHECKM2_MEGA/out
export CHECKM2_LOGS_E_MEGA=$CHECKM2_MEGA/err
# 12B CheckM2 - metaSPAdes
export CHECKM2_META=$CHECKM2_DIR/12B_metaspades
export CHECKM2_LOGS_O_META=$CHECKM2_META/out
export CHECKM2_LOGS_E_META=$CHECKM2_META/err
# 13 Read Taxonomy
export READ_TAX_DIR=$WORKING_DIR/13_READ_TAXONOMY
export READ_TAX_LOGS_O=$READ_TAX_DIR/out
export READ_TAX_LOGS_E=$READ_TAX_DIR/err
# 14A Contig Taxonomy - MEGAHIT
export CONTIG_TAX_DIR=$WORKING_DIR/14_CONTIG_TAXONOMY
export CONTIG_TAX_DIR_MEGA=$CONTIG_TAX_DIR/14A_contig_taxonomy_megahit
export CONTIG_LOGS_O_MEGA=$CONTIG_TAX_DIR_MEGA/out
export CONTIG_LOGS_E_MEGA=$CONTIG_TAX_DIR_MEGA/err
# 14B Contig Taxonomy - metaSPAdes
export CONTIG_TAX_DIR_META=$CONTIG_TAX_DIR/14B_contig_taxonomy_metaspades
export CONTIG_LOGS_O_META=$CONTIG_TAX_DIR_META/out
export CONTIG_LOGS_E_META=$CONTIG_TAX_DIR_META/err
# ---- End Directory Structure ----

# --- Job Parameters ---
# List of Jobs to run
export JOB1="01_wrapper_gen"
export JOB2="02_SRA_pull"
export JOB3="03_fastqc_before"
export JOB4="04_trimmomatic"
export JOB5="05_bowtie2"
export JOB6="06_fastqc_after"
export JOB7A="07A_megahit_assembly"
export JOB7B="07B_metaspades_assembly"
export JOB8A="08A_megahit_alignment"
export JOB8B="08B_metaspades_alignment"
export JOB9A="09A_megahit_concoct"
export JOB9B="09B_metaspades_concoct"
export JOB10="10_add_bin_nums"
export JOB11A="11A_megahit_quast"
export JOB11B="11B_metaspades_quast"
export JOB12A="12A_megahit_checkm2"
export JOB12B="12B_metaspades_checkm2"
export JOB13="13_read_taxonomy"
export JOB14A="14A_megahit_contig_taxonomy"
export JOB14B="14B_metaspades_contig_taxonomy"

export QUEUE="shared_memory"

# 01 Wrapper Gen
export JOB1_CPUS=1
export JOB1_QUEUE="${QUEUE}"
export JOB1_MEMORY="1GB"
export JOB1_TIME="0:05"
export CHUNK_SIZE=50
# 02 SRA Pull
export JOB2_CPUS=6
# 03 FastQC Before Trim
export JOB3_CPUS=1
export JOB3_QUEUE="${QUEUE}"
export JOB3_MEMORY="1GB"
export JOB3_TIME="02:00"
# 04 Trimmomatic
export JOB4_CPUS=4
export JOB4_QUEUE="${QUEUE}"
export JOB4_MEMORY="2GB"
export JOB4_TIME="04:30"
# 05 Bowtie2 Decontamination
export JOB5_CPUS=16
export JOB5_QUEUE="${QUEUE}"
export JOB5_MEMORY="8GB"
export JOB5_TIME="10:00"
# 06 FastQC After Trim
export JOB6_CPUS=1
export JOB6_QUEUE="${QUEUE}"
export JOB6_MEMORY="1GB"
export JOB6_TIME="02:00"
# 07A MEGAHIT Assembly
export JOB7A_CPUS=16
export JOB7A_QUEUE="${QUEUE}"
export JOB7A_MEMORY="16GB"
export JOB7A_MEMORY_GB=0.9  # MEGAHIT uses ratio (0.0-1.0) or exact value
export JOB7A_TIME="06:00"
# 07B metaSPAdes Assembly
export JOB7B_CPUS=20
export JOB7B_QUEUE="${QUEUE}"
export JOB7B_MEMORY="128GB"
export JOB7B_MEMORY_GB=128  # metaSPAdes uses GB value
export JOB7B_TIME="24:00"
# 08A Align MEGAHIT
export JOB8A_CPUS=8
export JOB8A_QUEUE="${QUEUE}"
export JOB8A_MEMORY="10GB"
export JOB8A_TIME="10:00"
# 08B Align metaSPAdes
export JOB8B_CPUS=8
export JOB8B_QUEUE="${QUEUE}"
export JOB8B_MEMORY="10GB"
export JOB8B_TIME="10:00"
# 09A CONCOCT/BWA Binning - MEGAHIT
export JOB9A_CPUS=24
export JOB9A_QUEUE="${QUEUE}"
export JOB9A_MEMORY="32GB"
export JOB9A_TIME="12:00"
# 09B CONCOCT/BWA Binning - metaspades
export JOB9B_CPUS=24
export JOB9B_QUEUE="${QUEUE}"
export JOB9B_MEMORY="32GB"
export JOB9B_TIME="12:00"
export CONCOCT_CHUNK_SIZE=10000
# 10 Add Bin Numbers (non-array job) (easy job -- will do both megahit and metaspades here)
export JOB10_CPUS=2
export JOB10_QUEUE="${QUEUE}"
export JOB10_MEMORY="2GB"
export JOB10_TIME="01:00"
# 11A QUAST MEGAHIT
export JOB11A_CPUS=8
export JOB11A_QUEUE="${QUEUE}"
export JOB11A_MEMORY="8GB"
export JOB11A_TIME="12:00"
# 11B QUAST metaSPAdes
export JOB11B_CPUS=8
export JOB11B_QUEUE="${QUEUE}"
export JOB11B_MEMORY="16GB"
export JOB11B_TIME="12:00"
# 12A CheckM2 MEGAHIT
export JOB12A_CPUS=24
export JOB12A_QUEUE="${QUEUE}"
export JOB12A_MEMORY="32GB"
export JOB12A_TIME="24:00"
# 12B CheckM2 metaSPAdes
export JOB12B_CPUS=24
export JOB12B_QUEUE="${QUEUE}"
export JOB12B_MEMORY="32GB"
export JOB12B_TIME="24:00"
# 13 Read Taxonomy
export JOB13_CPUS=24
export JOB13_QUEUE="${QUEUE}"
export JOB13_MEMORY="48GB"
export JOB13_TIME="12:00"
export KRAKEN2_KMER_SIZE=150  # Kraken2 k-mer size for Bracken
# 14A Contig Taxonomy MEGAHIT
export JOB14A_CPUS=24
export JOB14A_QUEUE="${QUEUE}"
export JOB14A_MEMORY="48GB"
export JOB14A_TIME="12:00"
# 14B Contig Taxonomy metaSPAdes
export JOB14B_CPUS=24
export JOB14B_QUEUE="${QUEUE}"
export JOB14B_MEMORY="48GB"
export JOB14B_TIME="12:00"


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
