#!/bin/bash

#BSUB -R "span[hosts=1]"
#BSUB -o "./${LOGS_DIR}/output.01A.%J_%I.log""
#BSUB -e "./${LOGS_DIR}/error.01A.%J_%I.log"

# This script runs the SRA Toolkit to gather reads files
pwd; hostname; date
source ./config.sh

# Initialize Parameters
JOBINDEX=$(($LSB_JOBINDEX -1))
names=($(cat ${WORKING_DIR}/sample_list))
NAME=${names[${JOBINDEX}]}
export DATA

export LOGS_DIR=./logs/


# Question -- can I chain pipeline files?
# i.e.. Job 1 tool kit has it's own pipeline
# launcher script? Once it finishes (three 
# jobs that depend on eachother 1-2-3 finishes)
# Then it'll kick off Fastqc & Trimmomatic
# at the same time.

aws s3 --no-sign-request cp s3://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/analysis_set/chm13v2.0.fa.gz