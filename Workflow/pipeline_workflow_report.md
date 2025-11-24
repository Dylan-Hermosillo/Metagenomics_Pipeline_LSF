# Metagenomics Pipeline Workflow

## Pipeline Overview
18-step metagenomics pipeline with dual assembly approaches (MEGAHIT & metaSPAdes) running in parallel from step 7 onward.

---

## Workflow Chain

```
01 → 02 → 03 → 04 → 05 → 07A/07B → 08A/08B → 09A/09B → 10 → 11A/11B
              ↓       ↓                                    ↓
              06      13                                 12A/12B
                      ↓
                    14A/14B
```

---

## Step-by-Step Breakdown

### **01. Wrapper Generation** (`01_wrapper_gen.sh`)
**Purpose:** Generate prefetch wrapper scripts for each SRA dataset  
**Dependency:** None  
**Output:** Individual wrapper scripts in `01_WRAPPER_GEN/scripts/`

**Key Code:**
```bash
COMMAND1="mkdir -p ${READS_DIR}/${DATA_NAME}"
COMMAND2="${APPT} exec ... prefetch ${DATA_NAME} -O ${READS_DIR}"
COMMAND3="${APPT} exec ... fasterq-dump ${DATA_NAME} --split-files"
```
Creates: `ERR9751998_prefetch_wrapper.sh` containing these three commands.

---

### **02. SRA Download** (Parallel Execution)
**Purpose:** Execute all wrappers in parallel to download FASTQ files  
**Dependency:** Job 01  
**Output:** `02_SRA_TOOLKIT/ERR9751998/ERR9751998/ERR9751998_1.fastq`, `ERR9751998_2.fastq`

Runs on login node with `-P 6` parallelization via `xargs`.

---

### **03. FastQC Before** (`03_fastqc_before.sh`)
**Purpose:** Quality control on raw reads  
**Dependency:** Job 02  
**Output:** HTML reports in `03_FASTQC_BEFORE/htmls/`

---

### **04. Trimmomatic** (`04_trimmomatic.sh`)
**Purpose:** Trim adapters and low-quality bases  
**Dependency:** Job 03  
**Output:** `04_TRIMMOMATIC/trimmed_reads/ERR9751998_R1_paired.fastq.gz`

**Key Parameters:**
```bash
ILLUMINACLIP:${ADAPTERS}:2:30:10 
SLIDINGWINDOW:4:20 
MINLEN:100 
HEADCROP:10
```

---

### **05. Bowtie2 Decontamination** (`05_bowtie2.sh`)
**Purpose:** Remove human reads  
**Dependency:** Job 04  
**Output:** `05_BOWTIE2/ERR9751998_1.fastq.gz` (decontaminated)

**Key Code:**
```bash
bowtie2 -x $REF_DB -1 $PAIR1 -2 $PAIR2 \
    --un-conc-gz ${CONTAM_DIR}/${NAME}_%.fastq.gz
```
`--un-conc-gz` outputs **only non-human reads** to `ERR9751998_1.fastq.gz` and `ERR9751998_2.fastq.gz`.

---

### **06. FastQC After** (`06_fastqc_after.sh`)
**Purpose:** QC on trimmed reads  
**Dependency:** Job 04  
**Output:** HTML reports in `06_FASTQC_AFTER/htmls/`

---

## Parallel Branch: Assembly & Analysis

### **07A/B. Assembly** (MEGAHIT & metaSPAdes)
**Purpose:** Assemble contigs from clean reads  
**Dependency:** Job 05  
**Output:**  
- MEGAHIT: `07_ASSEMBLY/07A_megahit_assembly/ERR9751998/final.contigs.fa`
- metaSPAdes: `07_ASSEMBLY/07B_metaspades_assembly/ERR9751998/contigs.fasta`

**File Naming Note:** MEGAHIT outputs `final.contigs.fa`, metaSPAdes outputs `contigs.fasta` - exact match required for downstream steps.

---

### **08A/B. Alignment** (BWA)
**Purpose:** Align clean reads back to assemblies  
**Dependency:** Job 07A/07B  
**Output:** `08_ALIGNMENT/08A_megahit/ERR9751998/sorted.bam`

**Key Steps:**
```bash
bwa index ${CONTIGS}
bwa mem ${CONTIGS} ${PAIR1} ${PAIR2} > result.sam
samtools view -b -F 4 result.sam > result.bam  # Keep mapped reads only
samtools sort result.bam > sorted.bam
samtools index sorted.bam
```

---

### **09A/B. CONCOCT Binning**
**Purpose:** Bin contigs into MAGs (Metagenome-Assembled Genomes)  
**Dependency:** Job 08A/08B  
**Output:** `09_BINNING/09A_concoct_megahit/ERR9751998/fasta_bins/0.fa`, `1.fa`, etc.

**Key Process:**
```bash
# Cut contigs into 10kb chunks
cut_up_fasta.py ${CONTIGS} --chunk_size 10000 > contigs_10k.fa

# Generate coverage from BAM
concoct_coverage_table.py contigs_10k.bed sorted.bam > coverage_table.tsv

# Cluster contigs by composition + coverage
concoct --composition_file contigs_10k.fa \
        --coverage_file coverage_table.tsv

# Extract bins
extract_fasta_bins.py ${CONTIGS} clustering_merged.csv \
    --output_path fasta_bins
```

Outputs numbered bins: `0.fa`, `1.fa`, `2.fa`... each representing a potential genome.

---

### **10. Add Bin Numbers** (`10_add_bin_nums.sh`)
**Purpose:** Prefix contig headers with bin numbers  
**Dependency:** Job 09A & 09B  
**Output:** `09_BINNING/09A_concoct_megahit/ERR9751998/ERR9751998.all_contigs.fna`

**Key Code:**
```bash
for file in *.fa; do
    num=$(echo $file | sed 's/.fa//')
    cat $num.fa | sed -e "s/^>/>${num}_/" >> ${NAME}.all_contigs.fna
done
```

**Example Transformation:**
```
Before (bin 0.fa):
>NODE_1_length_5432
ATCGATCG...

After (all_contigs.fna):
>0_NODE_1_length_5432
ATCGATCG...
```

This enables tracking which bin each contig belongs to.

---

### **11A/B. QUAST** (Assembly Quality)
**Purpose:** Assess assembly quality metrics  
**Dependency:** Job 09A/09B  
**Output:** `11_QUAST/11A_megahit/ERR9751998/report.html`

Reports: N50, L50, total length, largest contig, etc.

---

### **12A/B. CheckM2** (Bin Quality)
**Purpose:** Assess completeness/contamination of bins  
**Dependency:** Job 09A/09B  
**Output:** `12_CHECKM2/12A_megahit/ERR9751998/quality_report.tsv`

Determines which bins are high-quality MAGs (e.g., >90% complete, <5% contamination).

---

### **13. Read Taxonomy** (`13_read_taxonomy.sh`)
**Purpose:** Classify reads taxonomically  
**Dependency:** Job 05  
**Output:** `13_READ_TAXONOMY/ERR9751998/kraken_report.txt`

**Key Process:**
```bash
# Kraken2 classification
kraken2 --db ${KRAKEN2_DB} --paired ${PAIR1} ${PAIR2} \
    --output kraken_results.txt \
    --report kraken_report.txt

# Bracken abundance estimation
est_abundance.py -i kraken_report.txt -o bracken_results.txt

# Extract human/non-human reads
extract_kraken_reads.py --taxid 9606 --include-children  # Human
extract_kraken_reads.py --taxid 9606 --exclude           # Non-human
```

Separates human vs. non-human reads into subdirectories.

---

### **14A/B. Contig Taxonomy**
**Purpose:** Classify assembled contigs  
**Dependency:** Job 07A/07B  
**Output:** `14_CONTIG_TAXONOMY/14A_contig_taxonomy_megahit/ERR9751998/kraken_report.txt`

Same Kraken2/Bracken workflow as Step 13, but on assembled contigs instead of reads.

---

## Resource Configuration

From `config.sh`:
- **Heavy jobs:** 7B (metaSPAdes: 20 CPUs, 128GB), 12A/12B (CheckM2: 24 CPUs, 32GB)
- **Medium jobs:** 5 (Bowtie2: 16 CPUs), 7A (MEGAHIT: 16 CPUs)
- **Light jobs:** 3, 6 (FastQC: 1 CPU)

---

## Critical Dependencies

```
Job 5 (Decontamination) → Feeds 3 branches:
  ├─ 7A/7B (Assembly)
  ├─ 13 (Read Taxonomy)  
  └─ (via 7A/7B) → 14A/14B (Contig Taxonomy)

Job 9A/9B (Binning) → Feeds 3 steps:
  ├─ 10 (Add Bin Numbers)
  ├─ 11A/11B (QUAST)
  └─ 12A/12B (CheckM2)
```

All jobs use LSF array jobs (`[1-$NUM_JOB]`) for parallel sample processing.
