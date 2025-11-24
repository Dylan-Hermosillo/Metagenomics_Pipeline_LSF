# Metagenomics Pipeline LSF (Modular)

This document describes the modular metagenomics LSF pipeline. All changes should be made to the config file (working directory, database, run script locations, etc). 

Ensure all run_scripts are given execution rights and launch the job directly: **(./launch_pipeline.sh)**

This pipeline runs the complete workflow with proper dependency chains between all steps.

## PIPELINE STRUCTURE (Steps 01-14B):

```
01. Wrapper Generation
02. SRA Download (Parallel Execution)
03. FastQC Before Trim
04. Trimmomatic
05. Bowtie2 Decontamination
06. FastQC After Trim
07A. MEGAHIT Assembly
07B. metaSPAdes Assembly (parallel with 07A)
08A. Align to MEGAHIT
08B. Align to metaSPAdes (parallel with 08A)
09A. CONCOCT Binning MEGAHIT
09B. CONCOCT Binning metaSPAdes (parallel with 09A)
10. Add Bin Numbers (array job, processes both MEGAHIT and metaSPAdes)
11A. QUAST on Concatenated Bins MEGAHIT
11B. QUAST on Concatenated Bins metaSPAdes (parallel with 11A)
12A. CheckM2 on Bins MEGAHIT
12B. CheckM2 on Bins metaSPAdes (parallel with 12A)
13. Read Taxonomy (Kraken2/Bracken)
14A. Contig Taxonomy MEGAHIT (Kraken2/Bracken)
14B. Contig Taxonomy metaSPAdes (Kraken2/Bracken, parallel with 14A)
```

## Dependency Graph:
```
01 → 02 → 03 → 04 → 05 ─────────────────┐
              ↓       ↓                   ↓
              06      ├─→ 07A → 08A → 09A ┤
                      │    ↓              ├─→ 10 → 11A
                      │   14A             └────────→ 12A
                      │
                      ├─→ 07B → 08B → 09B ┤
                      │    ↓              ├─→ 10 → 11B
                      │   14B             └────────→ 12B
                      │
                      └─→ 13
```

## File List:
```
PIPELINE SCRIPTS:
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
| `ERR9751998_1.fastq`, `ERR9751998_2.fastq` | JOB2 | JOB3 |
| `ERR9751998_R1_paired.fastq.gz`, `ERR9751998_R2_paired.fastq.gz` | JOB4 | JOB5, JOB6 |
| `ERR9751998_1.fastq.gz`, `ERR9751998_2.fastq.gz` (clean) | JOB5 | JOB7A, JOB7B, JOB8A, JOB8B, JOB13 |
| `final.contigs.fa` (MEGAHIT) | JOB7A | JOB8A, JOB14A |
| `contigs.fasta` (metaSPAdes) | JOB7B | JOB8B, JOB14B |
| `sorted.bam` (MEGAHIT) | JOB8A | JOB9A |
| `sorted.bam` (metaSPAdes) | JOB8B | JOB9B |
| `fasta_bins/*.fa` (MEGAHIT) | JOB9A | JOB10, JOB12A |
| `fasta_bins/*.fa` (metaSPAdes) | JOB9B | JOB10, JOB12B |
| `ERR9751998.all_contigs.fna` (MEGAHIT) | JOB10 | JOB11A |
| `ERR9751998.all_contigs.fna` (metaSPAdes) | JOB10 | JOB11B |

---

# Pipeline Output Directory Structure for Sample ERR9751998

## Overview
This document describes the expected directory structure and file outputs for each pipeline step using sample accession ID `ERR9751998`.

---

## JOB1: Wrapper Generation
**Purpose:** Generate wrapper scripts for SRA prefetch and fasterq-dump

```
01_WRAPPER_GEN/
├── out/
│   └── wrapper.gen.{JOBID}.{ARRAY_INDEX}.log
├── err/
│   └── wrapper.gen.{JOBID}.{ARRAY_INDEX}.err
└── scripts/
    └── ERR9751998_prefetch_wrapper.sh
```

**Output Used By:**
- Wrapper scripts aggregated in `run_scripts/aggregate_prefetch_wrappers.txt` for JOB2

---

## JOB2: SRA Download (Parallel Execution)
**Purpose:** Download and extract FASTQ files from SRA

```
02_SRA_TOOLKIT/
├── out/
│   ├── ERR9751998_prefetch.log
│   └── ERR9751998_fasterq.log
├── err/
│   ├── ERR9751998_prefetch.err
│   └── ERR9751998_fasterq.err
└── ERR9751998/
    └── ERR9751998/
        ├── ERR9751998_1.fastq        ← Used by JOB3
        └── ERR9751998_2.fastq        ← Used by JOB3
```

**Note:** Runs on login node with `xargs -P 6` parallelization

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
│   ├── ERR9751998_1_fastqc.html
│   └── ERR9751998_2_fastqc.html
└── ERR9751998/
    ├── ERR9751998_1_fastqc.zip
    └── ERR9751998_2_fastqc.zip
```

**Input Dependencies:**
- `02_SRA_TOOLKIT/ERR9751998/ERR9751998/ERR9751998_1.fastq`
- `02_SRA_TOOLKIT/ERR9751998/ERR9751998/ERR9751998_2.fastq`

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
│   ├── ERR9751998_R1_paired.fastq.gz      ← Used by JOB5, JOB6
│   └── ERR9751998_R2_paired.fastq.gz      ← Used by JOB5, JOB6
└── unpaired_reads/
    ├── ERR9751998_R1_unpaired.fastq.gz
    └── ERR9751998_R2_unpaired.fastq.gz
```

**Input Dependencies:**
- `02_SRA_TOOLKIT/ERR9751998/ERR9751998/ERR9751998_1.fastq`
- `02_SRA_TOOLKIT/ERR9751998/ERR9751998/ERR9751998_2.fastq`

**Trimming Parameters:**
- `ILLUMINACLIP`: Remove adapters (2:30:10)
- `SLIDINGWINDOW`: Quality trimming (4:20)
- `MINLEN`: Minimum length 100bp
- `HEADCROP`: Remove first 10 bases

---

## JOB5: Bowtie2 Decontamination
**Purpose:** Remove host (human) contamination from reads

```
05_BOWTIE2/
├── out/
│   └── bowtie2.05.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── bowtie2.05.{JOBID}_{ARRAY_INDEX}.err
├── ERR9751998_1.fastq.gz                  ← Clean reads (used by JOB7A/7B, JOB8A/8B, JOB13)
├── ERR9751998_2.fastq.gz                  ← Clean reads (used by JOB7A/7B, JOB8A/8B, JOB13)
└── ERR9751998_hostmap.log
```

**Input Dependencies:**
- `04_TRIMMOMATIC/trimmed_reads/ERR9751998_R1_paired.fastq.gz`
- `04_TRIMMOMATIC/trimmed_reads/ERR9751998_R2_paired.fastq.gz`

**Key Outputs Used Downstream:**
- Clean reads → JOB7A, JOB7B, JOB8A, JOB8B, JOB13

**Note:** `ERR9751998_human_removed.sam` is created temporarily but deleted by the script.

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
│   ├── ERR9751998_R1_paired_fastqc.html
│   └── ERR9751998_R2_paired_fastqc.html
└── ERR9751998/
    ├── ERR9751998_R1_paired_fastqc.zip
    └── ERR9751998_R2_paired_fastqc.zip
```

**Input Dependencies:**
- `04_TRIMMOMATIC/trimmed_reads/ERR9751998_R1_paired.fastq.gz`
- `04_TRIMMOMATIC/trimmed_reads/ERR9751998_R2_paired.fastq.gz`

---

## JOB7A: MEGAHIT Assembly
**Purpose:** De novo metagenomic assembly using MEGAHIT

```
07_ASSEMBLY/07A_megahit_assembly/
├── out/
│   └── megahit_assembly.07A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── megahit_assembly.07A.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
    ├── final.contigs.fa              ← Primary assembly output (used by JOB8A, JOB14A)
    ├── intermediate_contigs/
    ├── k*.contigs.fa                 ← Various k-mer assemblies
    ├── options.json
    ├── checkpoints.txt
    └── log
```

**Input Dependencies:**
- `05_BOWTIE2/ERR9751998_1.fastq.gz`
- `05_BOWTIE2/ERR9751998_2.fastq.gz`

**Key Outputs Used Downstream:**
- `final.contigs.fa` → JOB8A, JOB14A

---

## JOB7B: metaSPAdes Assembly
**Purpose:** De novo metagenomic assembly using metaSPAdes

```
07_ASSEMBLY/07B_metaspades_assembly/
├── out/
│   └── metaspades_assembly.07B.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── metaspades_assembly.07B.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
    ├── contigs.fasta                 ← Primary assembly output (used by JOB8B, JOB14B)
    ├── scaffolds.fasta
    ├── assembly_graph.fastg
    ├── assembly_graph_with_scaffolds.gfa
    ├── before_rr.fasta
    ├── corrected/
    ├── K21/, K33/, K55/              ← k-mer directories
    ├── misc/
    ├── params.txt
    ├── spades.log
    └── warnings.log
```

**Input Dependencies:**
- `05_BOWTIE2/ERR9751998_1.fastq.gz`
- `05_BOWTIE2/ERR9751998_2.fastq.gz`

**Key Outputs Used Downstream:**
- `contigs.fasta` → JOB8B, JOB14B

---

## JOB8A: MEGAHIT Alignment
**Purpose:** Align clean reads back to MEGAHIT assembly using BWA

```
08_ALIGNMENT/08A_megahit/
├── out/
│   └── megahit_alignment.08A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── megahit_alignment.08A.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
    ├── sorted.bam                    ← Used by JOB9A
    └── sorted.bam.bai                ← BAM index
```

**Input Dependencies:**
- `05_BOWTIE2/ERR9751998_1.fastq.gz`
- `05_BOWTIE2/ERR9751998_2.fastq.gz`
- `07_ASSEMBLY/07A_megahit_assembly/ERR9751998/final.contigs.fa`

**Key Outputs Used Downstream:**
- `sorted.bam` → JOB9A

**BWA Index Files Created:**
- `final.contigs.fa.amb`, `.ann`, `.bwt`, `.pac`, `.sa`

**Note:** `result.sam` and `result.bam` are deleted after processing

---

## JOB8B: metaSPAdes Alignment
**Purpose:** Align clean reads back to metaSPAdes assembly using BWA

```
08_ALIGNMENT/08B_metaspades/
├── out/
│   └── metaspades_alignment.08B.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── metaspades_alignment.08B.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
    ├── sorted.bam                    ← Used by JOB9B
    └── sorted.bam.bai                ← BAM index
```

**Input Dependencies:**
- `05_BOWTIE2/ERR9751998_1.fastq.gz`
- `05_BOWTIE2/ERR9751998_2.fastq.gz`
- `07_ASSEMBLY/07B_metaspades_assembly/ERR9751998/contigs.fasta`

**Key Outputs Used Downstream:**
- `sorted.bam` → JOB9B

**BWA Index Files Created:**
- `contigs.fasta.amb`, `.ann`, `.bwt`, `.pac`, `.sa`

**Note:** `result.sam` and `result.bam` are deleted after processing

---

## JOB9A: MEGAHIT CONCOCT Binning
**Purpose:** Bin MEGAHIT contigs into MAGs using CONCOCT

```
09_BINNING/09A_concoct_megahit/
├── out/
│   └── megahit_concoct.09A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── megahit_concoct.09A.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
    ├── contigs_10k.fa
    ├── contigs_10k.bed
    ├── coverage_table.tsv
    ├── clustering_gt1000.csv
    ├── clustering_merged.csv         ← Final clustering
    ├── args.txt
    ├── log.txt
    └── fasta_bins/                   ← Used by JOB10, JOB12A
        ├── 0.fa
        ├── 1.fa
        ├── 2.fa
        └── ...
```

**Input Dependencies:**
- `07_ASSEMBLY/07A_megahit_assembly/ERR9751998/final.contigs.fa`
- `08_ALIGNMENT/08A_megahit/ERR9751998/sorted.bam`

**Key Outputs Used Downstream:**
- `fasta_bins/*.fa` → JOB10, JOB12A

**Process:**
1. Cut contigs into 10kb chunks
2. Generate coverage table from BAM
3. Cluster by composition + coverage
4. Extract bins as separate FASTA files

---

## JOB9B: metaSPAdes CONCOCT Binning
**Purpose:** Bin metaSPAdes contigs into MAGs using CONCOCT

```
09_BINNING/09B_concoct_metaspades/
├── out/
│   └── metaspades_concoct.09B.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── metaspades_concoct.09B.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
    ├── contigs_10k.fa
    ├── contigs_10k.bed
    ├── coverage_table.tsv
    ├── clustering_gt1000.csv
    ├── clustering_merged.csv         ← Final clustering
    ├── args.txt
    ├── log.txt
    └── fasta_bins/                   ← Used by JOB10, JOB12B
        ├── 0.fa
        ├── 1.fa
        ├── 2.fa
        └── ...
```

**Input Dependencies:**
- `07_ASSEMBLY/07B_metaspades_assembly/ERR9751998/contigs.fasta`
- `08_ALIGNMENT/08B_metaspades/ERR9751998/sorted.bam`

**Key Outputs Used Downstream:**
- `fasta_bins/*.fa` → JOB10, JOB12B

---

## JOB10: Add Bin Numbers
**Purpose:** Add bin numbers to contig headers and concatenate all bins

```
09_BINNING/09A_concoct_megahit/ERR9751998/
    └── ERR9751998.all_contigs.fna         ← Concatenated bins (used by JOB11A)

09_BINNING/09B_concoct_metaspades/ERR9751998/
    └── ERR9751998.all_contigs.fna         ← Concatenated bins (used by JOB11B)

10_ADD_BIN_NUMS/
├── out/
│   └── add_bin_nums.10.{JOBID}_{ARRAY_INDEX}.log
└── err/
    └── add_bin_nums.10.{JOBID}_{ARRAY_INDEX}.err
```

**Input Dependencies:**
- `09_BINNING/09A_concoct_megahit/ERR9751998/fasta_bins/*.fa`
- `09_BINNING/09B_concoct_metaspades/ERR9751998/fasta_bins/*.fa`

**Key Outputs Used Downstream:**
- `ERR9751998.all_contigs.fna` (MEGAHIT) → JOB11A
- `ERR9751998.all_contigs.fna` (metaSPAdes) → JOB11B

**Contig Header Transformation:**
```
Before (bin 0.fa):  >NODE_1_length_5432
After:              >0_NODE_1_length_5432
```

---

## JOB11A: MEGAHIT QUAST
**Purpose:** Assembly quality assessment for MEGAHIT bins

```
11_QUAST/11A_megahit/
├── out/
│   └── megahit_quast.11A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── megahit_quast.11A.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
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
    │   └── ERR9751998.all_contigs_GC_content_plot.pdf
    ├── contigs_reports/
    └── quast.log
```

**Input Dependencies:**
- `09_BINNING/09A_concoct_megahit/ERR9751998/ERR9751998.all_contigs.fna`

**Metrics Reported:**
- N50, L50, total length, largest contig, GC content, etc.

---

## JOB11B: metaSPAdes QUAST
**Purpose:** Assembly quality assessment for metaSPAdes bins

```
11_QUAST/11B_metaspades/
├── out/
│   └── metaspades_quast.11B.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── metaspades_quast.11B.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
    ├── report.txt
    ├── report.html
    ├── report.pdf
    ├── report.tsv
    ├── transposed_report.txt
    ├── transposed_report.tsv
    ├── icarus.html
    ├── icarus_viewers/
    ├── basic_stats/
    ├── contigs_reports/
    └── quast.log
```

**Input Dependencies:**
- `09_BINNING/09B_concoct_metaspades/ERR9751998/ERR9751998.all_contigs.fna`

---

## JOB12A: MEGAHIT CheckM2
**Purpose:** Assess completeness and contamination of MEGAHIT bins

```
12_CHECKM2/12A_megahit/
├── out/
│   └── megahit_checkm.12A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── megahit_checkm.12A.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
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
- `09_BINNING/09A_concoct_megahit/ERR9751998/fasta_bins/*.fa`

**Key Output:**
- `quality_report.tsv`: Completeness, contamination, and quality scores for each bin

**Quality Thresholds:**
- High-quality MAG: >90% complete, <5% contamination
- Medium-quality MAG: ≥50% complete, <10% contamination

---

## JOB12B: metaSPAdes CheckM2
**Purpose:** Assess completeness and contamination of metaSPAdes bins

```
12_CHECKM2/12B_metaspades/
├── out/
│   └── metaspades_checkm.12B.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── metaspades_checkm.12B.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
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
- `09_BINNING/09B_concoct_metaspades/ERR9751998/fasta_bins/*.fa`

---

## JOB13: Read Taxonomy
**Purpose:** Taxonomic classification of reads with Kraken2/Bracken

```
13_READ_TAXONOMY/
├── out/
│   └── read_taxonomy.13.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── read_taxonomy.13.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
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
- `05_BOWTIE2/ERR9751998_1.fastq.gz`
- `05_BOWTIE2/ERR9751998_2.fastq.gz`

**Key Outputs:**
- `kraken_report.txt`: Hierarchical taxonomic report
- `bracken_results.txt`: Re-estimated taxonomic abundances at species level
- `human_reads/`: Reads classified as human (taxid 9606)
- `nonhuman_reads/`: Reads classified as non-human

**Process:**
1. Kraken2 classification with memory-mapping
2. Bracken abundance estimation
3. Extract human/non-human reads using KrakenTools

---

## JOB14A: MEGAHIT Contig Taxonomy
**Purpose:** Taxonomic classification of MEGAHIT contigs with Kraken2/Bracken

```
14_CONTIG_TAXONOMY/14A_contig_taxonomy_megahit/
├── out/
│   └── contig_taxonomy.14A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── contig_taxonomy.14A.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
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
- `07_ASSEMBLY/07A_megahit_assembly/ERR9751998/final.contigs.fa`

**Key Outputs:**
- `kraken_report.txt`: Hierarchical taxonomic report for contigs
- `bracken_results.txt`: Re-estimated taxonomic abundances
- `human_contigs/`: Contigs classified as human
- `nonhuman_contigs/`: Contigs classified as non-human

---

## JOB14B: metaSPAdes Contig Taxonomy
**Purpose:** Taxonomic classification of metaSPAdes contigs with Kraken2/Bracken

```
14_CONTIG_TAXONOMY/14B_contig_taxonomy_metaspades/
├── out/
│   └── contig_taxonomy.14A.{JOBID}_{ARRAY_INDEX}.log
├── err/
│   └── contig_taxonomy.14A.{JOBID}_{ARRAY_INDEX}.err
└── ERR9751998/
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
- `07_ASSEMBLY/07B_metaspades_assembly/ERR9751998/contigs.fasta`

**Key Outputs:**
- `kraken_report.txt`: Hierarchical taxonomic report for contigs
- `bracken_results.txt`: Re-estimated taxonomic abundances
- `human_contigs/`: Contigs classified as human
- `nonhuman_contigs/`: Contigs classified as non-human

---

## Complete Pipeline Flow Summary

```
01_WRAPPER_GEN
    ↓
02_SRA_TOOLKIT (parallel download)
    ↓
03_FASTQC_BEFORE
    ↓
04_TRIMMOMATIC
    ↓
05_BOWTIE2 ──────────────────────┐
    ↓                            ↓
06_FASTQC_AFTER          13_READ_TAXONOMY
    ↓
┌───┴────┐
│        │
07A      07B (assemblies)
│        │
↓        ↓
14A      14B (contig taxonomy)
│        │
↓        ↓
08A      08B (alignments)
│        │
↓        ↓
09A      09B (CONCOCT binning)
│        │
└───┬────┘
    ↓
   10 (add bin numbers)
    │
┌───┴────┐
│        │
11A      11B (QUAST)
│        │
12A      12B (CheckM2)
```

---

## Notes

1. **Parallel Branches**: MEGAHIT (7A→8A→9A→11A/12A) and metaSPAdes (7B→8B→9B→11B/12B) run independently after JOB5
2. **Temporary Files**: Intermediate files (`.sam`, unsorted `.bam`) are deleted after processing
3. **Index Files**: BWA creates index files (`.amb`, `.ann`, `.bwt`, `.pac`, `.sa`) alongside assemblies
4. **Database Requirements**:
   - CheckM2 database at `$CHECKM2_DB`
   - Kraken2 database at `$KRAKEN2_DB` with kmer distribution files for Bracken
   - Human reference genome at `$REF_DB` for Bowtie2
5. **Array Job Logs**: `{JOBID}` is the LSF job ID, `{ARRAY_INDEX}` is the array task index (1-based)
6. **Memory-Mapping**: All Kraken2 jobs (JOB13, JOB14A, JOB14B) use `--memory-mapping` flag for efficient database access
7. **Job 10**: Processes both MEGAHIT and metaSPAdes bins in a single array job per sample
