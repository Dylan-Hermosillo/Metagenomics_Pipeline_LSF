!/bin/bash
#BSUB -n 8
#BSUB -W 4:00
#BSUB -J bowtie2
#BSUB -o stdout.%J
#BSUB -e stderr.%J
#BSUB -R "rusage[mem=32GB]"
#BSUB -M 32000
#BSUB -q "shared_memory"
module load conda
source ~/.bashrc
conda activate /usr/local/usrapps/ivirus/dhermos/env_metag
cd /share/ivirus/dhermos/bowtie2_hum_db

bowtie2-build --threads 8 chm13v2.0.fa chm13v2.0_index

conda deactivate
