# Metagenomics Pipeline LSF (Modular)

This document describes the modular metagenomics LSF pipeline. All changes should be made to the config file (working directory, database, run script locations, etc). Ensure all run_scripts are given execution rights and launch the job directly: **(./launch_pipeline.sh)**

## PIPELINE STRUCTURE (Steps 01-10B):

```
01. Wrapper Generation
02. SRA Download
03. FastQC Before Trim
04. Trimmomatic
05. Bowtie2 Decontamination
06. FastQC After Trim
07A. MEGAHIT Assembly
07B. metaSPAdes Assembly (parallel with 07A)
08A. Align to MEGAHIT
08B. Align to metaSPAdes (parallel with 08A)
09A. CONCOCT Binning (1=MEGAHIT, 2=metaSPADES)
09B. Add Bin Numbers (all samples, non-array)
09C. QUAST on Concatenated Bins (1=MEGAHIT, 2=metaSPADES)
09D. CheckM2 on Bins (1=MEGAHIT, 2=metaSPADES)
10A. Read Taxonomy (Kraken2/Bracken)
10B. Contig Taxonomy (Kraken2/Bracken)
```
## Dependency Graph:
```

                                    01 (Wrapper Gen)
                                     ↓
                                    02 (SRA Download)
                                     ↓
                                    03 (FastQC Before)
                                     ↓
                                    04 (Trimmomatic)
                                     ↓              ↓
                                    05 (Bowtie2)   06 (FastQC After)
                                     ↓
                    ┌────────────────┼────────────────┐
                    ↓                ↓                ↓
                  07A (MEGAHIT)    07B (metaSPAdes)  10A (Read Tax)
                    ↓                ↓
                  08A (Align)      08B (Align)
                    ↓                
                  10B (Contig Tax)
                    ↓                             ***(1=MEGAHIT, 2=metaSPAdes)***
                  09A1/2 (CONCOCT)
                    ↓              ↓
                  09D1/2 (CheckM2)   09B (Add Bin Nums) 
                                   ↓
                                  09C1/2 (QUAST)
                                  
```
## File List:
```
01_wrapper_gen.sh
03_fastqc_before.sh
04_trimmomatic.sh
05_bowtie2.sh
06_fastqc_after.sh
07A_megahit.sh (FIXED version)
07B_metaspades.sh (FIXED version)
08A_align_megahit.sh          
08B_align_metaspades.sh       
09A_1_megahit_concoct.sh     \\ 1=MEGAHIT             
09A_2_metaspades_concoct.sh  \\ 2=metaSPAdes
09B_add_bin_nums.sh           
09C_1_megahit_quast.sh                  
09C_2_metaspades_quast.sh                  
09D_1_megahit_checkm.sh                 
09D_2_metaspades_checkm.sh                 
10A_read_taxonomy.sh          
10B_contig_taxonomy.sh        

CONFIGURATION & LAUNCHER:
config.sh             - Complete config with all variables
launch_pipeline.sh    - Complete launcher with all jobs
```

## Key Components Directory Structure:
```
$WORKING_DIR/
  ├── 08_ALIGNMENT/
  │   ├── 08A_megahit/
  │   │   ├── out/
  │   │   ├── err/
  │   │   └── [SAMPLE]/
  │   │       ├── sorted.bam
  │   │       └── sorted.bam.bai
  │   └── 08B_metaspades/
  │       ├── out/
  │       ├── err/
  │       └── [SAMPLE]/
  │           ├── sorted.bam
  │           └── sorted.bam.bai
  ├── 09_BINNING/
  │   ├── 09A_1_megahit_concoct/
  │   │   ├── out/
  │   │   ├── err/
  │   │   ├── [SAMPLE]/
  │   │   │   ├── fasta_bins/
  │   │   │   │   ├── 0.fa
  │   │   │   │   ├── 1.fa
  │   │   │   │   └── ...
  │   │   │   ├── contigs_10k.fa
  │   │   │   ├── contigs_10k.bed
  │   │   │   ├── coverage_table.tsv
  │   │   │   └── clustering_merged.csv
  │   │   └── [SAMPLE].all_contigs.fna (from 09B)
  |   |   
  |   |── 09A_2_metaspades_concoct/
  │   │   ├── out/
  │   │   ├── err/
  │   │   ├── [SAMPLE]/
  │   │   │   ├── fasta_bins/
  │   │   │   │   ├── 0.fa
  │   │   │   │   ├── 1.fa
  │   │   │   │   └── ...
  │   │   │   ├── contigs_10k.fa
  │   │   │   ├── contigs_10k.bed
  │   │   │   ├── coverage_table.tsv
  │   │   │   └── clustering_merged.csv
  │   │   └── [SAMPLE].all_contigs.fna (from 09B)
  │   │
  │   ├── 09C__1_megahit_quast/
  │   │   ├── out/
  │   │   ├── err/
  │   │   └── [SAMPLE]/
  │   │       └── report.html
  │   │
  │   │── 09C__2_metaspades_quast/
  │   │   ├── out/
  │   │   ├── err/
  │   │   └── [SAMPLE]/
  │   │       └── report.html
  │   │
  │   │── 09D_1_megahit_checkm/
  │   │   ├── out/
  │   │   ├── err/
  │   │   └── [SAMPLE]/
  │   │       └── quality_report.tsv
  │   │
  │   └── 09D_1_megahit_checkm/
  │       ├── out/
  │       ├── err/
  │       └── [SAMPLE]/
  │           └── quality_report.tsv
  │
  └── 10_TAXONOMY/
      ├── 10A_read_taxonomy/
      │   ├── out/
      │   ├── err/
      │   └── [SAMPLE]/
      │       ├── kraken_report.txt
      │       ├── bracken_results.txt
      │       ├── human_reads/
      │       │   ├── r1.fq.gz
      │       │   └── r2.fq.gz
      │       └── nonhuman_reads/
      │           ├── r1.fq.gz
      │           └── r2.fq.gz
      └── 10B_contig_taxonomy/
          ├── out/
          ├── err/
          └── [SAMPLE]/
              ├── kraken_report.txt
              ├── bracken_results.txt
              ├── human_contigs/
              │   └── contigs.fa.gz
              └── nonhuman_contigs/
                  └── contigs.fa.gz
```

## Pipeline Summary
```
================================================================================
COMPLETE PIPELINE SUMMARY
================================================================================

Total Steps: 18 jobs (01-10B)
  • 16 array jobs (process each sample)
  • 1 pre-processing jobs (02 -- NOT LSF, Runs Parallel via xargs to download data)
  • 1 non-array job (09B processes all samples)

Parallelization Points:
  • 07A & 07B (assemblies)
  • 08A & 08B (alignments)
  • 09D1/2 with 09B/09C1/2 (CheckM2 independent of QUAST)
  • 10A & 10B (independent taxonomy branches)

Critical Path:
  01 → 02 → 03 → 04 → 05 → 07A → 08A → 09A1/2 → 09B → 09C1/2
  (Approximately 100-150 hours for full dataset, but samples run in parallel)

Expected Runtime per Sample:
  • Assembly (07A): ~24h
  • Alignment (08A): ~8h
  • Binning (09A): ~24h
  • QC (09C/09D): ~12-16h
  • Taxonomy (10A/10B): ~8-16h
  • Total: ~80-100h per sample (but all run concurrently)
  ```