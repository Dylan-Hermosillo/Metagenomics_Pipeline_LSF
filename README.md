# Metagenomics Pipeline LSF (Modular)

This document describes the modular metagenomics LSF pipeline. All changes should be made to the config file (working directory, database, run script locations, etc). 

Ensure all run_scripts are given execution rights and launch the job directly: **(./launch_pipeline.sh)**

This pipeline has two options; 
1) Workflow that runs in it's entirety.
2) Modular that can run independent steps.

## PIPELINE STRUCTURE (Steps 01-14B):

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
09A. CONCOCT Binning MEGAHIT
09B. CONCOCT Binning metaSPAdes
10. Add Bin Numbers (all samples, non-array)
11A. QUAST on Concatenated Bins MEGAHIT
11B. QUAST on Concatenated Bins metaSPAdes
12A. CheckM2 on Bins MEGAHIT
12B. CheckM2 on Bins metaSPAdes
13. Read Taxonomy (Kraken2/Bracken)
14A. Contig Taxonomy MEGAHIT (Kraken2/Bracken)
14B. Contig Taxonomy metaSPAdes (Kraken2/Bracken)
```
## Dependency Graph:
```
01_wrapper_gen → 02_SRA_pull → 03_fastqc_before → 04_trimmomatic → 05_bowtie2
                                                           ↓
                                                    06_fastqc_after
                                                           ↓
                                          ┌──────── 07A_megahit ────────┐
                                          │              ↓              │
                                          │      08A_alignment          │
                                          │              ↓              │
                                          │       09A_concoct           │
                                          │           ↓  ↓  ↓           │
                                          │    11A_quast │ 12A_checkm2  │
                                          │              ↓              │
                                          │       10_add_bin_nums       │
                                          │                             │
                                          │      14A_contig_taxonomy    │
                                          └─────────────────────────────┘
                                          
                                          ┌────── 07B_metaspades ───────┐
                                          │              ↓              │
                                          │      08B_alignment          │
                                          │              ↓              │
                                          │       09B_concoct           │
                                          │           ↓  ↓  ↓           │
                                          │    11B_quast │ 12B_checkm2  │
                                          │              ↓              │
                                          │       10_add_bin_nums       │
                                          │                             │
                                          │      14B_contig_taxonomy    │
                                          └─────────────────────────────┘
                                                         
                                 05_bowtie2 → 13_read_taxonomy                            
```
## File List:
```
01_wrapper_gen.sh
03_fastqc_before.sh
04_trimmomatic.sh
05_bowtie2.sh
06_fastqc_after.sh
07A_megahit_assembly.sh
07B_metaspades_assembly.sh
08A_megahit_alignment.sh
08B_metaspades_alignment.sh
09A_megahit_concoct.sh
09B_metaspades_concoct.sh
10_add_bin_nums.sh
11A_megahit_quast.sh
11B_metaspades_quast.sh
12A_megahit_checkm2.sh
12B_metaspades_checkm2.sh
13_read_taxonomy.sh
14A_megahit_contig_taxonomy.sh
14B_metaspades_contig_taxonomy.sh    

CONFIGURATION & LAUNCHER:
config.sh             - Complete config with all variables
launch_pipeline.sh    - Complete launcher with all jobs
```

---

## Key File Pointers Between Steps

| Output File | Produced By | Used By |
|------------|-------------|---------|
| `ERR81_1.fastq.gz`, `ERR81_2.fastq.gz` | JOB5 | JOB7A, JOB7B, JOB8A, JOB8B, JOB13 |
| `final.contigs.fa` (MEGAHIT) | JOB7A | JOB8A, JOB14A |
| `contigs.fasta` (metaSPAdes) | JOB7B | JOB8B, JOB14B |
| `sorted.bam` (MEGAHIT) | JOB8A | JOB9A |
| `sorted.bam` (metaSPAdes) | JOB8B | JOB9B |
| `fasta_bins/*.fa` (MEGAHIT) | JOB9A | JOB10, JOB12A |
| `fasta_bins/*.fa` (metaSPAdes) | JOB9B | JOB10, JOB12B |
| `ERR81.all_contigs.fna` (MEGAHIT) | JOB10 | JOB11A |
| `ERR81.all_contigs.fna` (metaSPAdes) | JOB10 | JOB11B |

---
# Pipeline Output Directory Structure for Sample ERR81

## Overview
This document describes the expected directory structure and file outputs for each pipeline step using sample accession ID `ERR81`.

---

## JOB3: FastQC Before Trimming
**Purpose:** Quality control on raw reads before trimming

```
03_FASTQC_BEFORE/
├── out/
│   └── fastqc.03.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── fastqc.03.{JOBID}_{ARRAY_INDEX}.err
├── htmls/
│   ├── ERR81_1_fastqc.html
│   └── ERR81_2_fastqc.html
├── ERR81_1_fastqc.zip
└── ERR81_2_fastqc.zip
```

**Input Dependencies:**
- `02_SRA_TOOLKIT/ERR81/ERR81/ERR81_1.fastq`
- `02_SRA_TOOLKIT/ERR81/ERR81/ERR81_2.fastq`

---

## JOB4: Trimmomatic
**Purpose:** Adapter trimming and quality filtering

```
04_TRIMMOMATIC/
├── out/
│   └── trim.04.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── trim.04.{JOBID}_{ARRAY_INDEX}.err
├── trimmed_reads/
│   ├── ERR81_R1_paired.fastq.gz      ← Used by downstream steps
│   └── ERR81_R2_paired.fastq.gz      ← Used by downstream steps
└── unpaired_reads/
    ├── ERR81_R1_unpaired.fastq.gz
    └── ERR81_R2_unpaired.fastq.gz
```

**Input Dependencies:**
- `02_SRA_TOOLKIT/ERR81/ERR81/ERR81_1.fastq`
- `02_SRA_TOOLKIT/ERR81/ERR81/ERR81_2.fastq`

**Key Outputs Used Downstream:**
- Paired reads → JOB5, JOB6

---

## JOB5: Bowtie2 Decontamination
**Purpose:** Remove host (human) contamination from reads

```
05_BOWTIE2/
├── out/
│   └── bowtie2.05.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── bowtie2.05.{JOBID}_{ARRAY_INDEX}.err
├── ERR81_1.fastq.gz                  ← Clean reads (used by JOB7A/7B, JOB8A/8B, JOB13)
├── ERR81_2.fastq.gz                  ← Clean reads (used by JOB7A/7B, JOB8A/8B, JOB13)
└── ERR81_hostmap.log
```

**Input Dependencies:**
- `04_TRIMMOMATIC/trimmed_reads/ERR81_R1_paired.fastq.gz`
- `04_TRIMMOMATIC/trimmed_reads/ERR81_R2_paired.fastq.gz`

**Key Outputs Used Downstream:**
- Clean reads → JOB7A, JOB7B, JOB8A, JOB8B, JOB13

**Note:** `ERR81_human_removed.sam` is created temporarily but deleted by the script.

---

## JOB6: FastQC After Trimming
**Purpose:** Quality control on trimmed reads

```
06_FASTQC_AFTER/
├── out/
│   └── fastqc.06.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── fastqc.06.{JOBID}_{ARRAY_INDEX}.err
├── htmls/
│   ├── ERR81_R1_paired_fastqc.html
│   └── ERR81_R2_paired_fastqc.html
├── ERR81_R1_paired_fastqc.zip
└── ERR81_R2_paired_fastqc.zip
```

**Input Dependencies:**
- `04_TRIMMOMATIC/trimmed_reads/ERR81_R1_paired.fastq.gz`
- `04_TRIMMOMATIC/trimmed_reads/ERR81_R2_paired.fastq.gz`

---

## JOB7A: MEGAHIT Assembly
**Purpose:** De novo metagenomic assembly using MEGAHIT

```
07_ASSEMBLY/07A_megahit_assembly/
├── out/
│   └── megahit.07A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── megahit.07A.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── final.contigs.fa              ← Primary assembly output (used by JOB8A, JOB14A)
    ├── intermediate_contigs/
    ├── k21.contigs.fa
    ├── k41.contigs.fa
    ├── k61.contigs.fa
    ├── k81.contigs.fa
    ├── k99.contigs.fa
    ├── k119.contigs.fa
    ├── k141.contigs.fa
    ├── options.json
    ├── checkpoints.txt
    └── log
```

**Input Dependencies:**
- `05_BOWTIE2/ERR81_1.fastq.gz`
- `05_BOWTIE2/ERR81_2.fastq.gz`

**Key Outputs Used Downstream:**
- `final.contigs.fa` → JOB8A, JOB14A

---

## JOB7B: metaSPAdes Assembly
**Purpose:** De novo metagenomic assembly using metaSPAdes

```
07_ASSEMBLY/07B_metaspades_assembly/
├── out/
│   └── metaspades.07B.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── metaspades.07B.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── contigs.fasta                 ← Primary assembly output (used by JOB8B, JOB14B)
    ├── scaffolds.fasta
    ├── assembly_graph.fastg
    ├── assembly_graph_with_scaffolds.gfa
    ├── before_rr.fasta
    ├── corrected/
    ├── K21/
    ├── K33/
    ├── K55/
    ├── misc/
    ├── params.txt
    ├── spades.log
    └── warnings.log
```

**Input Dependencies:**
- `05_BOWTIE2/ERR81_1.fastq.gz`
- `05_BOWTIE2/ERR81_2.fastq.gz`

**Key Outputs Used Downstream:**
- `contigs.fasta` → JOB8B, JOB14B

---

## JOB8A: MEGAHIT Alignment
**Purpose:** Align clean reads back to MEGAHIT assembly

```
08_ALIGNMENT/08A_megahit/
├── out/
│   └── align_megahit.08A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── align_megahit.08A.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── sorted.bam                    ← Primary alignment output (used by JOB9A)
    └── sorted.bam.bai                ← BAM index
```

**Input Dependencies:**
- `07_ASSEMBLY/07A_megahit_assembly/ERR81/final.contigs.fa`
- `05_BOWTIE2/ERR81_1.fastq.gz`
- `05_BOWTIE2/ERR81_2.fastq.gz`

**Key Outputs Used Downstream:**
- `sorted.bam` → JOB9A

**Note:** BWA index files (`.amb`, `.ann`, `.bwt`, `.pac`, `.sa`) created alongside `final.contigs.fa`

---

## JOB8B: metaSPAdes Alignment
**Purpose:** Align clean reads back to metaSPAdes assembly

```
08_ALIGNMENT/08B_metaspades/
├── out/
│   └── align_metaspades.08B.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── align_metaspades.08B.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── sorted.bam                    ← Primary alignment output (used by JOB9B)
    └── sorted.bam.bai                ← BAM index
```

**Input Dependencies:**
- `07_ASSEMBLY/07B_metaspades_assembly/ERR81/contigs.fasta`
- `05_BOWTIE2/ERR81_1.fastq.gz`
- `05_BOWTIE2/ERR81_2.fastq.gz`

**Key Outputs Used Downstream:**
- `sorted.bam` → JOB9B

**Note:** BWA index files (`.amb`, `.ann`, `.bwt`, `.pac`, `.sa`) created alongside `contigs.fasta`

---

## JOB9A: MEGAHIT CONCOCT Binning
**Purpose:** Bin MEGAHIT contigs into MAGs (Metagenome-Assembled Genomes)

```
09_BINNING/09A_concoct_megahit/
├── out/
│   └── concoct.09A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── concoct.09A.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── contigs_10k.fa
    ├── contigs_10k.bed
    ├── coverage_table.tsv
    ├── clustering_gt1000.csv
    ├── clustering_merged.csv         ← Used by JOB10
    ├── args.txt
    ├── log.txt
    ├── original_data_gt1000.csv
    ├── PCA_transformed_data_gt1000.csv
    └── fasta_bins/                   ← Bin FASTAs (used by JOB10, JOB12A)
        ├── 0.fa
        ├── 1.fa
        ├── 2.fa
        ├── 3.fa
        └── ...
```

**Input Dependencies:**
- `07_ASSEMBLY/07A_megahit_assembly/ERR81/final.contigs.fa`
- `08_ALIGNMENT/08A_megahit/ERR81/sorted.bam`

**Key Outputs Used Downstream:**
- `fasta_bins/*.fa` → JOB10, JOB12A
- `clustering_merged.csv` → JOB10

---

## JOB9B: metaSPAdes CONCOCT Binning
**Purpose:** Bin metaSPAdes contigs into MAGs

```
09_BINNING/09A_concoct_metaspades/
├── out/
│   └── concoct.09A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── concoct.09A.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── contigs_10k.fa
    ├── contigs_10k.bed
    ├── coverage_table.tsv
    ├── clustering_gt1000.csv
    ├── clustering_merged.csv         ← Used by JOB10
    ├── args.txt
    ├── log.txt
    ├── original_data_gt1000.csv
    ├── PCA_transformed_data_gt1000.csv
    └── fasta_bins/                   ← Bin FASTAs (used by JOB10, JOB12B)
        ├── 0.fa
        ├── 1.fa
        ├── 2.fa
        ├── 3.fa
        └── ...
```

**Input Dependencies:**
- `07_ASSEMBLY/07B_metaspades_assembly/ERR81/contigs.fasta`
- `08_ALIGNMENT/08B_metaspades/ERR81/sorted.bam`

**Key Outputs Used Downstream:**
- `fasta_bins/*.fa` → JOB10, JOB12B
- `clustering_merged.csv` → JOB10

---

## JOB10: Add Bin Numbers
**Purpose:** Add bin identifiers to contig headers and concatenate all bins

```
09_BINNING
├── 09A_concoct_megahit/
│   └── ERR81.all_contigs.fna         ← Concatenated bins (used by JOB11A)
└── 09A_concoct_metaspades/
    └── ERR81.all_contigs.fna         ← Concatenated bins (used by JOB11B)
10_ADD_BIN_NUMS/
├── out/
│   └── add_bin_nums.10.{JOBID}_{ARRAY_INDEX}.log
└── err/
    └── add_bin_nums.10.{JOBID}_{ARRAY_INDEX}.err
```

**Input Dependencies:**
- `09_BINNING/09A_concoct_megahit/ERR81/fasta_bins/*.fa`
- `09_BINNING/09A_concoct_metaspades/ERR81/fasta_bins/*.fa`

**Key Outputs Used Downstream:**
- `ERR81.all_contigs.fna` (MEGAHIT) → JOB11A
- `ERR81.all_contigs.fna` (metaSPAdes) → JOB11B

**Note:** Each contig header is modified from `>NODE_123` to `>0_NODE_123`, `>1_NODE_123`, etc.

---

## JOB11A: MEGAHIT QUAST
**Purpose:** Assembly quality assessment for MEGAHIT bins

```
11_QUAST/11A_megahit
├── out/
│   └── quast.11A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── quast.11A.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── report.txt
    ├── report.html
    ├── report.pdf
    ├── report.tsv
    ├── transposed_report.txt
    ├── transposed_report.tsv
    ├── icarus.html
    ├── icarus_viewers/
    ├── basic_stats/
    │   ├── cumulative_plot.pdf
    │   ├── GC_content_plot.pdf
    │   └── ERR81.all_contigs_GC_content_plot.pdf
    ├── contigs_reports/
    └── quast.log
```

**Input Dependencies:**
- `09_BINNING/09A_concoct_megahit/ERR81.all_contigs.fna`

---

## JOB11B: metaSPAdes QUAST
**Purpose:** Assembly quality assessment for metaSPAdes bins

```
11_QUAST/1B_metaspades/
├── out/
│   └── quast.11B.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── quast.11B.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── report.txt
    ├── report.html
    ├── report.pdf
    ├── report.tsv
    ├── transposed_report.txt
    ├── transposed_report.tsv
    ├── icarus.html
    ├── icarus_viewers/
    ├── basic_stats/
    │   ├── cumulative_plot.pdf
    │   ├── GC_content_plot.pdf
    │   └── ERR81.all_contigs_GC_content_plot.pdf
    ├── contigs_reports/
    └── quast.log
```

**Input Dependencies:**
- `09_BINNING/09A_concoct_metaspades/ERR81.all_contigs.fna`

---

## JOB12A: MEGAHIT CheckM2
**Purpose:** Assess completeness and contamination of MEGAHIT bins

```
12_CHECKM2/12A_megahit/
├── out/
│   └── checkm.12A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── checkm.12A.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── quality_report.tsv            ← Primary quality metrics
    ├── protein_files/
    │   ├── 0.faa
    │   ├── 1.faa
    │   ├── 2.faa
    │   └── ...
    ├── diamond_output/
    └── checkm2.log
```

**Input Dependencies:**
- `09_BINNING/09A_concoct_megahit/ERR81/fasta_bins/*.fa`

**Key Output:**
- `quality_report.tsv`: Contains completeness, contamination, and quality scores for each bin

---

## JOB12B: metaSPAdes CheckM2
**Purpose:** Assess completeness and contamination of metaSPAdes bins

```
12_CHECKM2/12B_metaspades/
├── out/
│   └── checkm.12B.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── checkm.12B.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── quality_report.tsv            ← Primary quality metrics
    ├── protein_files/
    │   ├── 0.faa
    │   ├── 1.faa
    │   ├── 2.faa
    │   └── ...
    ├── diamond_output/
    └── checkm2.log
```

**Input Dependencies:**
- `09_BINNING/09A_concoct_metaspades/ERR81/fasta_bins/*.fa`

**Key Output:**
- `quality_report.tsv`: Contains completeness, contamination, and quality scores for each bin

---

## JOB13: Read Taxonomy
**Purpose:** Taxonomic classification of reads with Kraken2/Bracken

```
13_TAXONOMY/13_read_taxonomy/
├── out/
│   └── read_taxonomy.13.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── read_taxonomy.13.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── kraken_results.txt
    ├── kraken_report.txt
    ├── bracken_results.txt
    ├── kraken_report_bracken_species.txt
    ├── cseqs_1.fq                    ← Classified sequences
    ├── cseqs_2.fq                    ← Classified sequences
    ├── human_reads/
    │   ├── r1.fq.gz
    │   └── r2.fq.gz
    └── nonhuman_reads/
        ├── r1.fq.gz
        └── r2.fq.gz
```

**Input Dependencies:**
- `05_BOWTIE2/ERR81_1.fastq.gz`
- `05_BOWTIE2/ERR81_2.fastq.gz`

**Key Outputs:**
- `kraken_report.txt`: Hierarchical taxonomic report
- `bracken_results.txt`: Re-estimated taxonomic abundances
- `human_reads/`: Reads classified as human (taxid 9606)
- `nonhuman_reads/`: Reads classified as non-human

---

## JOB14A: MEGAHIT Contig Taxonomy
**Purpose:** Taxonomic classification of MEGAHIT contigs with Kraken2/Bracken

```
14_CONTIG_TAXONOMY/14A_megahit_contig_taxonomy/
├── out/
│   └── contig_taxonomy.14A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── contig_taxonomy.14A.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── kraken_results.txt
    ├── kraken_report.txt
    ├── bracken_results.txt
    ├── kraken_report_bracken_species.txt
    ├── cseqs#.fa                     ← Classified contigs
    ├── human_contigs/
    │   └── contigs.fa.gz
    └── nonhuman_contigs/
        └── contigs.fa.gz
```

**Input Dependencies:**
- `07_ASSEMBLY/07A_megahit_assembly/ERR81/final.contigs.fa`

**Key Outputs:**
- `kraken_report.txt`: Hierarchical taxonomic report for contigs
- `bracken_results.txt`: Re-estimated taxonomic abundances
- `human_contigs/`: Contigs classified as human
- `nonhuman_contigs/`: Contigs classified as non-human

---

## JOB14B: metaSPAdes Contig Taxonomy
**Purpose:** Taxonomic classification of metaSPAdes contigs with Kraken2/Bracken

```
14_CONTIG_TAXONOMY/14B_metaspades_contig_taxonomy/
├── out/
│   └── contig_taxonomy.14B.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── contig_taxonomy.14B.{JOBID}_{ARRAY_INDEX}.err
└── ERR81/
    ├── kraken_results.txt
    ├── kraken_report.txt
    ├── bracken_results.txt
    ├── kraken_report_bracken_species.txt
    ├── cseqs#.fa                     ← Classified contigs
    ├── human_contigs/
    │   └── contigs.fa.gz
    └── nonhuman_contigs/
        └── contigs.fa.gz
```

**Input Dependencies:**
- `07_ASSEMBLY/07B_metaspades_assembly/ERR81/contigs.fasta`

**Key Outputs:**
- `kraken_report.txt`: Hierarchical taxonomic report for contigs
- `bracken_results.txt`: Re-estimated taxonomic abundances
- `human_contigs/`: Contigs classified as human
- `nonhuman_contigs/`: Contigs classified as non-human

---

## Complete Pipeline Flow Summary

```
02_SRA_TOOLKIT (input data)
    ↓
03_FASTQC_BEFORE
    ↓
04_TRIMMOMATIC
    ↓
05_BOWTIE2 ────────────────────┐
    ↓                          ↓
06_FASTQC_AFTER           13_READ_TAXONOMY
    ↓
┌───┴───┐
│       │
07A     07B (assemblies)
│       │
↓       ↓
14A     14B (contig taxonomy)
│       │
↓       ↓
08A     08B (alignments)
│       │
↓       ↓
09A     09B (CONCOCT binning)
│       │
↓───┬───↓
    │
   10 (add bin numbers)
    │
┌───┴───┐
│       │
11A     11B (QUAST)
│       │
12A     12B (CheckM2)
```
## Notes

1. **Parallel Branches**: MEGAHIT (7A→8A→9A→11A/12A) and metaSPAdes (7B→8B→9B→11B/12B) run independently after JOB5
2. **Temporary Files**: Some intermediate files (e.g., `result.sam`, `result.bam`) are deleted after processing
3. **Index Files**: BWA creates index files alongside assemblies (`.amb`, `.ann`, `.bwt`, `.pac`, `.sa`)
4. **CheckM2 Database**: Requires `$CHECKM2_DB` to be mounted and accessible
5. **Kraken2 Database**: Requires `$KRAKEN2_DB` to be mounted with kmer distribution files for Bracken
6. **Array Job Logs**: `{JOBID}` is the LSF job ID, `{ARRAY_INDEX}` is the array task index (1-based)