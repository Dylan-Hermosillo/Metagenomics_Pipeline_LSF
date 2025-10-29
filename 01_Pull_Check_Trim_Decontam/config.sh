# Working Dir
export WORKING_DIR=/share/ivirus/dhermos

# Logs Dir
export LOGS_DIR=./logs/

# Files -- change this txt to a list of your SRR id's
export XFILE=$WORKING_DIR/project1_ids.txt

# Reads Dir for SRA Toolkit output
export READS_DIR=$WORKING_DIR/01_SRA_TOOLKIT/reads

# QC Outputs
export FASTQ_DIR=$WORKING_DIR/02_FASTQC/
export FASTQ_BEFORE=$FASTQ_DIR/before_trimming
export FASTQ_AFTER=$FASTQ_DIR/after_trimming

# Trimming
export TRIM_DIR=$WORKING_DIR/03_TRIMMOMATIC/
export TRIMMED_READ=$TRIM_DIR/trimmed_reads
export U

# Contam Removal
export CONTAM_DIR=$WORKING_DIR/04_Bowtie2/
