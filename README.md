# Metagenomics Pipeline LSF

This pipeline is an agnostic lsf driven pipeline. All changes are made in the config.sh files to chain tools together.

### Sections:

1. Pull/Check/Trim/Decontam
    This first section pulls reads through the NCBI Sequence Read Archive (SRA) using their SRA TOOLKIT. Followed by a quick pre-trim/decontam quality check of the reads using FASTQC. Adapters are trimmed and contamination (human in our case...mostly) is carried out with TRIMMOMATIC/BOWTIE. A final post-quality check is carried out by FASTQC again.
2. Assembly_Binning
3. Kraken/Bracken
4. Functional Analysis