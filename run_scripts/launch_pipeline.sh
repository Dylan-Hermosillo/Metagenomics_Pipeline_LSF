#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_pipeline_lsf
#BSUB -o launch_pipeline_lsf.%J.out
#BSUB -e launch_pipeline_lsf.%J.err

# NOTE: MAKE ALL PARAMETER CHANGES IN THE CONFIG.SH FILE!!!

# --- Housekeeping ---
# load config
source ./config.sh
# Working Dir -- should be made already but just in case...
create_dir $WORKING_DIR $RUN_SCRIPTS
# get sample list & export number of samples
if [[ ! -f ${XFILE} ]]; then
    echo "Sample list file ${XFILE} not found!"
    exit 1
fi
# get number of jobs
export NUM_JOB=$(wc -l < "${XFILE}")
# --- End Housekeeping ---

# --- Create File Structure ---
# 01 In/Out for Wrapper Generation
create_dir $WRAP_OUT $WRAP_SCRIPTS $WRAP_LOGS_O $WRAP_LOGS_E
# 02 Reads Dir (SRA Toolkit output)
create_dir $READS_DIR $SRA_LOGS_O $SRA_LOGS_E
# 03 FastQC Before Trim Outputs
create_dir $FASTQC_BEFORE $FASTQC_LOGS_O $FASTQC_LOGS_E $FASTQC_B_HTML
# 04 Trimmomatic Outputs
create_dir $TRIM_DIR $TRIMMED $UNPAIRED $TRIM_LOGS_O $TRIM_LOGS_E
# 05 Bowtie2 Decontamination Outputs
create_dir $CONTAM_DIR $CONTAM_LOGS_O $CONTAM_LOGS_E
# 06 FastQC After Trim Outputs
create_dir $FASTQC_AFTER $FASTQC_AFTER_LOGS_O $FASTQC_AFTER_LOGS_E $FASTQC_A_HTML
# 07 Assemblers
create_dir $ASSEM_DIR $MEGAHIT_DIR $MEGAHIT_LOGS_O $MEGAHIT_LOGS_E # MEGAHIT
create_dir $METASPADES_DIR $METASPADES_LOGS_O $METASPADES_LOGS_E # metaSPAdes
# 08 Alignment Outputs
create_dir $ALIGN_DIR $ALIGN_MEGAHIT_DIR $ALIGN_MEGAHIT_LOGS_O $ALIGN_MEGAHIT_LOGS_E # MEGAHIT
create_dir $ALIGN_METASPADES_DIR $ALIGN_METASPADES_LOGS_O $ALIGN_METASPADES_LOGS_E # metaSPAdes
# 09A Binning
create_dir $BINNING_DIR $CONCOCT_MEGA $CONCOCT_LOGS_O $CONCOCT_LOGS_E # MEGAHIT
create_dir $CONCOCT_META $CONCOCT_LOGS_O_META $CONCOCT_LOGS_E_META # metaSPAdes
# 09C QUAST
create_dir $QUAST_DIR $QUAST_MEGA $QUAST_LOGS_O_MEGA $QUAST_LOGS_E_MEGA # MEGAHIT
create_dir $QUAST_META $QUAST_LOGS_O_META $QUAST_LOGS_E_META # metaSPAdes
# 09D CheckM2
create_dir $CHECKM_DIR $CHECKM_MEGA $CHECKM_LOGS_O_MEGA $CHECKM_LOGS_E_MEGA # MEGAHIT
create dir $CHECKM_META $CHECKM_LOGS_O_META $CHECKM_LOGS_E_META # metaSPAdes
# 10 Taxonomy Outputs
create_dir $TAXONOMY_DIR $READ_TAX_DIR $READ_TAX_LOGS_O $READ_TAX_LOGS_E # MEGAHIT
create_dir $CONTIG_TAX_DIR $CONTIG_TAX_LOGS_O $CONTIG_TAX_LOGS_E # metaSPAdes
# --- End Create File Structure ---

# --- Launch Pipeline Steps ---
# Job 1: Generate LSF Wrappers
echo "Launching Job 1: LSF Wrapper Generation"
JOBID1=$(bsub -J "$JOB1[1-$NUM_JOB]%$NUM_JOB" \
     -n $JOB1_CPUS \
     -q $JOB1_QUEUE \
     -R "rusage[mem=$JOB1_MEMORY]" \
     -o "${WRAP_LOGS_O}/wrapper.gen.%J.%I.log" \
     -e "${WRAP_LOGS_E}/wrapper.gen.%J.%I.err" \
     -W $JOB1_TIME \
     < ${RUN_SCRIPTS}/${JOB1}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 1 array with ID $JOBID1"
bwait -w "done($JOBID1)"

# Job 2: SRA Download
AGGREGATE_FILE="${RUN_SCRIPTS}/aggregate_prefetch_wrappers.txt"
# Verify aggregate file exists
if [[ ! -s "$AGGREGATE_FILE" ]]; then
    echo "ERROR: No wrappers were generated!"
    echo "Check logs in: $WRAP_LOGS_E/"
    exit 1
fi
echo "Launching Job 2: SRA Download (parallel on login node)"
if [[ -s "$AGGREGATE_FILE" ]]; then
    # Execute all wrappers in parallel on login node
    START_TIME=$(date +%s)
    cat "$AGGREGATE_FILE" | xargs -P $JOB2_CPUS -I {} bash {}
    JOB2_EXIT=$?
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    if [[ $JOB2_EXIT -ne 0 ]]; then
        echo "ERROR: Job 2 (parallel execution) failed with exit code $JOB2_EXIT"
        exit 1
    fi
fi
echo "Job 2 completed successfully in ${DURATION}s"

# Job 3: FastQC Before Trim
echo "Launching Job 3: FastQC Before Trim"
JOBID3=$(bsub -J "$JOB3[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB3_CPUS \
    -q $JOB3_QUEUE \
    -R "rusage[mem=$JOB3_MEMORY]" \
    -W $JOB3_TIME \
    -o "${FASTQC_LOGS_O}/fastqc.03.%J_%I.log" \
    -e "${FASTQC_LOGS_E}/fastqc.03.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB3}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 3 array with ID $JOBID3"

# Job 4: Trimmomatic
echo "Launching Job 4: Trimmomatic"
JOBID4=$(bsub -J "$JOB4[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB4_CPUS \
    -q $JOB4_QUEUE \
    -R "rusage[mem=$JOB4_MEMORY]" \
    -W $JOB4_TIME \
    -w "done($JOBID3)" \
    -o "${TRIM_LOGS_O}/trim.04.%J_%I.log" \
    -e "${TRIM_LOGS_E}/trim.04.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB4}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 4 array with ID $JOBID4"

# Job 5: Bowtie2 Decontamination
echo "Launching Job 5: Bowtie2 Decontamination"
JOBID5=$(bsub -J "$JOB5[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB5_CPUS \
    -q $JOB5_QUEUE \
    -R "rusage[mem=$JOB5_MEMORY]" \
    -W $JOB5_TIME \
    -w "done($JOBID4)" \
    -o "${CONTAM_LOGS_O}/bowtie2.05.%J_%I.log" \
    -e "${CONTAM_LOGS_E}/bowtie2.05.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB5}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 5 array with ID $JOBID5"

# Job 6: FastQC After Trim
echo "Launching Job 6: FastQC After Trim"
JOBID6=$(bsub -J "$JOB6[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB6_CPUS \
    -q $JOB6_QUEUE \
    -R "rusage[mem=$JOB6_MEMORY]" \
    -W $JOB6_TIME \
    -w "done($JOBID4)" \
    -o "${FASTQC_AFTER_LOGS_O}/fastqc.06.%J_%I.log" \
    -e "${FASTQC_AFTER_LOGS_E}/fastqc.06.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB6}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 6 array with ID $JOBID6"

# Job 7A: MEGAHIT Assembly (runs concurrently with 7B)
echo "Launching Job 7A: MEGAHIT Assembly"
JOBID7A=$(bsub -J "$JOB7A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB7A_CPUS \
    -q $JOB7A_QUEUE \
    -R "rusage[mem=$JOB7A_MEMORY]" \
    -W $JOB7A_TIME \
    -w "done($JOBID5)" \
    -o "${MEGAHIT_LOGS_O}/megahit.07A.%J_%I.log" \
    -e "${MEGAHIT_LOGS_E}/megahit.07A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB7A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 7A array with ID $JOBID7A"

# Job 7B: metaSPAdes Assembly (runs concurrently with 7A)
echo "Launching Job 7B: metaSPAdes Assembly"
JOBID7B=$(bsub -J "$JOB7B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB7B_CPUS \
    -q $JOB7B_QUEUE \
    -R "rusage[mem=$JOB7B_MEMORY]" \
    -W $JOB7B_TIME \
    -w "done($JOBID5)" \
    -o "${METASPADES_LOGS_O}/metaspades.07B.%J_%I.log" \
    -e "${METASPADES_LOGS_E}/metaspades.07B.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB7B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 7B array with ID $JOBID7B"

# Job 8A: Align to MEGAHIT (depends on 7A)
echo "Launching Job 8A: Align to MEGAHIT"
JOBID8A=$(bsub -J "$JOB8A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB8A_CPUS \
    -q $JOB8A_QUEUE \
    -R "rusage[mem=$JOB8A_MEMORY]" \
    -W $JOB8A_TIME \
    -w "done($JOBID7A)" \
    -o "${ALIGN_MEGAHIT_LOGS_O}/align_megahit.08A.%J_%I.log" \
    -e "${ALIGN_MEGAHIT_LOGS_E}/align_megahit.08A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB8A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 8A array with ID $JOBID8A"

# Job 8B: Align to metaSPAdes (depends on 7B)
echo "Launching Job 8B: Align to metaSPAdes"
JOBID8B=$(bsub -J "$JOB8B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB8B_CPUS \
    -q $JOB8B_QUEUE \
    -R "rusage[mem=$JOB8B_MEMORY]" \
    -W $JOB8B_TIME \
    -w "done($JOBID7B)" \
    -o "${ALIGN_METASPADES_LOGS_O}/align_metaspades.08B.%J_%I.log" \
    -e "${ALIGN_METASPADES_LOGS_E}/align_metaspades.08B.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB8B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 8B array with ID $JOBID8B"

# Job 9A1: CONCOCT Binning (depends on 8A) - MEGAHIT
echo "Launching Job 9A: CONCOCT Binning"
JOBID9A1=$(bsub -J "$JOB9A1[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB9A1_CPUS \
    -q $JOB9A1_QUEUE \
    -R "rusage[mem=$JOB9A1_MEMORY]" \
    -W $JOB9A1_TIME \
    -w "done($JOBID8A)" \
    -o "${CONCOCT_LOGS_O_MEGA}/concoct.09A.%J_%I.log" \
    -e "${CONCOCT_LOGS_E_MEGA}/concoct.09A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB9A1}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9A array with ID $JOBID9A1"

# Job 9A2: CONCOCT Binning (depends on 8A) - metaSPAdes
echo "Launching Job 9A: CONCOCT Binning"
JOBID9A2=$(bsub -J "$JOB9A2[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB9A2_CPUS \
    -q $JOB9A2_QUEUE \
    -R "rusage[mem=$JOB9A2_MEMORY]" \
    -W $JOB9A2_TIME \
    -w "done($JOBID8A)" \
    -o "${CONCOCT_LOGS_O_META}/concoct.09A.%J_%I.log" \
    -e "${CONCOCT_LOGS_E_META}/concoct.09A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB9A2}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9A array with ID $JOBID9A2"

# Job 9B1: Add Bin Numbers (depends on 9A1 & 9A2, non-array job)
echo "Launching Job 9B: Add Bin Numbers"
JOBID9B=$(bsub -J "$JOB9B" \
    -n $JOB9B_CPUS \
    -q $JOB9B_QUEUE \
    -R "rusage[mem=$JOB9B_MEMORY]" \
    -W $JOB9B_TIME \
    -w "done($JOBID9A1) && done($JOBID9A2)"  \ # ensure both 9A1 and 9A2 are done
    -o "${CONCOCT_LOGS_O}/add_bin_nums.09B.%J.log" \
    -e "${CONCOCT_LOGS_E}/add_bin_nums.09B.%J.err" \
    < $RUN_SCRIPTS/${JOB9B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9B with ID $JOBID9B"

# Job 9C1: QUAST (depends on 9B) - MEGAHIT
echo "Launching Job 9C: QUAST"
JOBID9C1=$(bsub -J "$JOB9C1[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB9C1_CPUS \
    -q $JOB9C1_QUEUE \
    -R "rusage[mem=$JOB9C1_MEMORY]" \
    -W $JOB9C1_TIME \
    -w "done($JOBID9B)" \
    -o "${QUAST_LOGS_O_MEGA}/quast.09C.%J_%I.log" \
    -e "${QUAST_LOGS_E_MEGA}/quast.09C.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB9C1}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9C array with ID $JOBID9C1"

# Job 9C1: QUAST (depends on 9B) - metaSPAdes
echo "Launching Job 9C: QUAST"
JOBID9C2=$(bsub -J "$JOB9C2[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB9C2_CPUS \
    -q $JOB9C2_QUEUE \
    -R "rusage[mem=$JOB9C2_MEMORY]" \
    -W $JOB9C2_TIME \
    -w "done($JOBID9B)" \
    -o "${QUAST_LOGS_O_META}/quast.09C.%J_%I.log" \
    -e "${QUAST_LOGS_E_META}/quast.09C.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB9C2}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9C array with ID $JOBID9C2"

# Job 9D1: CheckM2 (depends on 9A1, runs concurrently with 9B/9C) MEGAHIT
echo "Launching Job 9D: CheckM2"
JOBID9D1=$(bsub -J "$JOB9D1[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB9D1_CPUS \
    -q $JOB9D1_QUEUE \
    -R "rusage[mem=$JOB9D1_MEMORY]" \
    -W $JOB9D1_TIME \
    -w "done($JOBID9A1)" \
    -o "${CHECKM_LOGS_O_MEGA}/checkm.09D.%J_%I.log" \
    -e "${CHECKM_LOGS_E_MEGA}/checkm.09D.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB9D1}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9D array with ID $JOBID9D1"

# Job 9D21: CheckM2 (depends on 9A2, runs concurrently with 9B/9C) metaSPAdes
echo "Launching Job 9D: CheckM2"
JOBID9D2=$(bsub -J "$JOB9D2[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB9D2_CPUS \
    -q $JOB9D2_QUEUE \
    -R "rusage[mem=$JOB9D2_MEMORY]" \
    -W $JOB9D2_TIME \
    -w "done($JOBID9A2)" \
    -o "${CHECKM_LOGS_O_META}/checkm.09D.%J_%I.log" \
    -e "${CHECKM_LOGS_E_META}/checkm.09D.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB9D2}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9D array with ID $JOBID9D2"

# Job 10A: Read Taxonomy (depends on 5, runs independently)
echo "Launching Job 10A: Read Taxonomy"
JOBID10A=$(bsub -J "$JOB10A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB10A_CPUS \
    -q $JOB10A_QUEUE \
    -R "rusage[mem=$JOB10A_MEMORY]" \
    -W $JOB10A_TIME \
    -w "done($JOBID5)" \
    -o "${READ_TAX_LOGS_O}/read_taxonomy.10A.%J_%I.log" \
    -e "${READ_TAX_LOGS_E}/read_taxonomy.10A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB10A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 10A array with ID $JOBID10A"

# Job 10B: Contig Taxonomy (depends on 7A)
echo "Launching Job 10B: Contig Taxonomy"
JOBID10B=$(bsub -J "$JOB10B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB10B_CPUS \
    -q $JOB10B_QUEUE \
    -R "rusage[mem=$JOB10B_MEMORY]" \
    -W $JOB10B_TIME \
    -w "done($JOBID7A)" \
    -o "${CONTIG_TAX_LOGS_O}/contig_taxonomy.10B.%J_%I.log" \
    -e "${CONTIG_TAX_LOGS_E}/contig_taxonomy.10B.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB10B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 10B array with ID $JOBID10B"

# --- End Launch Pipeline Steps ---
echo ""
echo "All jobs submitted successfully!"
echo "Pipeline flow:"
echo "  1 → 2 → 3 → 4 → 5 → (7A & 7B) & 10A"
echo "              ↓           ↓       ↓"
echo "              6          8A      10B"
echo "                          ↓"
echo "                         9A1/2 → 9B1/2 → 9C1/2 (1=MEGAHIT, 2=metaSPAdes)"
echo "                          ↓"
echo "                         9D1/2 (1=MEGAHIT, 2=metaSPAdes)"
