#!/bin/bash
#BSUB -n 8
#BSUB -W 4:00
#BSUB -J mycode
#BSUB -o stdout.%J
#BSUB -e stderr.%J
#BSUB -R "rusage[mem=32000]"
#BSUB -M 32000
source ~/.bashrc
conda activate /usr/local/usrapps/$GROUP/$USER/env_mycode
cd /share/ivirus/dhermos/bowtie2_hum_db

bowtie2-build --threads 8 chm13v2.0.fa chm13v2.0_index

conda deactivate