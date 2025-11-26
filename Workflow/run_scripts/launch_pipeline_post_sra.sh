#! /bin/bash
#BSUB -n 1
#BSUB -W 12:00
#BSUB -q "shared_memory"
#BSUB -J launch_pipeline_lsf
#BSUB -o ./launch_pipeline_post_sra_lsf.%J.out
#BSUB -e ./launch_pipeline_post_sra_lsf.%J.err

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

# --- Create File Structure ---
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
# 09 Binning
create_dir $BINNING_DIR $CONCOCT_MEGA $CONCOCT_LOGS_O_MEGA $CONCOCT_LOGS_E_MEGA # MEGAHIT
create_dir $CONCOCT_META $CONCOCT_LOGS_O_META $CONCOCT_LOGS_E_META # metaSPAdes
# 10 Add Bin Numbers
create_dir $ADD_BIN_DIR $ADD_BIN_LOGS_O $ADD_BIN_LOGS_E
# 11 QUAST
create_dir $QUAST_DIR $QUAST_MEGA $QUAST_LOGS_O_MEGA $QUAST_LOGS_E_MEGA # MEGAHIT
create_dir $QUAST_META $QUAST_LOGS_O_META $QUAST_LOGS_E_META # metaSPAdes
# 12 CheckM2
create_dir $CHECKM2_DIR $CHECKM2_MEGA $CHECKM2_LOGS_O_MEGA $CHECKM2_LOGS_E_MEGA # MEGAHIT
create_dir $CHECKM2_META $CHECKM2_LOGS_O_META $CHECKM2_LOGS_E_META # metaSPAdes
# 13 Reads Taxonomy Outputs
create_dir $READ_TAX_DIR $READ_TAX_LOGS_O $READ_TAX_LOGS_E # Reads
# 14 Contig Taxonomy Outputs
create_dir $CONTIG_TAX_DIR $CONTIG_TAX_DIR_MEGA $CONTIG_LOGS_O_MEGA $CONTIG_LOGS_E_MEGA # MEGAHIT
create_dir $CONTIG_TAX_DIR_META $CONTIG_LOGS_O_META $CONTIG_LOGS_E_META # metaSPAdes
# --- End Create File Structure ---
# --- End Housekeeping ---

# --- Launch Pipeline Steps ---

# Job 3: FastQC Before Trim
echo "Launching Job 3: FastQC Before Trim"
JOBID3=$(bsub -J "$JOB3[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB3_CPUS \
    -q $JOB3_QUEUE \
    -R "rusage[mem=$JOB3_MEMORY]" \
    -M $JOB3_MEMORY \
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
    -M $JOB4_MEMORY \
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
    -M $JOB5_MEMORY \
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
    -M $JOB6_MEMORY \
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
    -M $JOB7A_MEMORY \
    -W $JOB7A_TIME \
    -w "done($JOBID5)" \
    -o "${MEGAHIT_LOGS_O}/megahit_assembly.07A.%J_%I.log" \
    -e "${MEGAHIT_LOGS_E}/megahit_assembly.07A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB7A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 7A array with ID $JOBID7A"

# Job 7B: metaSPAdes Assembly (runs concurrently with 7A)
echo "Launching Job 7B: metaSPAdes Assembly"
JOBID7B=$(bsub -J "$JOB7B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB7B_CPUS \
    -q $JOB7B_QUEUE \
    -R "rusage[mem=$JOB7B_MEMORY]" \
    -M $JOB7B_MEMORY \
    -W $JOB7B_TIME \
    -w "done($JOBID5)" \
    -o "${METASPADES_LOGS_O}/metaspades_assembly.07B.%J_%I.log" \
    -e "${METASPADES_LOGS_E}/metaspades_assembly.07B.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB7B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 7B array with ID $JOBID7B"

# Job 8A: Align to MEGAHIT (depends on 7A)
echo "Launching Job 8A: Align to MEGAHIT"
JOBID8A=$(bsub -J "$JOB8A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB8A_CPUS \
    -q $JOB8A_QUEUE \
    -R "rusage[mem=$JOB8A_MEMORY]" \
    -M $JOB8A_MEMORY \
    -W $JOB8A_TIME \
    -w "done($JOBID7A)" \
    -o "${ALIGN_MEGAHIT_LOGS_O}/megahit_alignment.08A.%J_%I.log" \
    -e "${ALIGN_MEGAHIT_LOGS_E}/megahit_alignment.08A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB8A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 8A array with ID $JOBID8A"

# Job 8B: Align to metaSPAdes (depends on 7B)
echo "Launching Job 8B: Align to metaSPAdes"
JOBID8B=$(bsub -J "$JOB8B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB8B_CPUS \
    -q $JOB8B_QUEUE \
    -R "rusage[mem=$JOB8B_MEMORY]" \
    -M $JOB8B_MEMORY \
    -W $JOB8B_TIME \
    -w "done($JOBID7B)" \
    -o "${ALIGN_METASPADES_LOGS_O}/metaspades_alignment.08B.%J_%I.log" \
    -e "${ALIGN_METASPADES_LOGS_E}/metaspades_alignment.08B.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB8B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 8B array with ID $JOBID8B"

# Job 9A: CONCOCT Binning (depends on 8A) - MEGAHIT
echo "Launching Job 9A: CONCOCT Binning"
JOBID9A=$(bsub -J "$JOB9A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB9A_CPUS \
    -q $JOB9A_QUEUE \
    -R "rusage[mem=$JOB9A_MEMORY]" \
    -M $JOB9A_MEMORY \
    -W $JOB9A_TIME \
    -w "done($JOBID8A)" \
    -o "${CONCOCT_LOGS_O_MEGA}/megahit_concoct.09A.%J_%I.log" \
    -e "${CONCOCT_LOGS_E_MEGA}/megahit_concoct.09A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB9A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9A array with ID $JOBID9A"

# Job 9B: CONCOCT Binning (depends on 8B) - metaSPAdes
echo "Launching Job 9B: CONCOCT Binning"
JOBID9B=$(bsub -J "$JOB9B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB9B_CPUS \
    -q $JOB9B_QUEUE \
    -R "rusage[mem=$JOB9B_MEMORY]" \
    -M $JOB9B_MEMORY \
    -W $JOB9B_TIME \
    -w "done($JOBID8B)" \
    -o "${CONCOCT_LOGS_O_META}/metaspades_concoct.09B.%J_%I.log" \
    -e "${CONCOCT_LOGS_E_META}/metaspades_concoct.09B.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB9B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 9B array with ID $JOBID9B"

# Job 10: Add Bin Numbers (depends on 9A & 9B)
echo "Launching Job 10: Add Bin Numbers"
JOBID10=$(bsub -J "$JOB10[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB10_CPUS \
    -q $JOB10_QUEUE \
    -R "rusage[mem=$JOB10_MEMORY]" \
    -M $JOB10_MEMORY \
    -W $JOB10_TIME \
    -w "done($JOBID9A) && done($JOBID9B)" \
    -o "${ADD_BIN_LOGS_O}/add_bin_nums.10.%J_%I.log" \
    -e "${ADD_BIN_LOGS_E}/add_bin_nums.10.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB10}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 10 array with ID $JOBID10"

# Job 11A: QUAST (depends on 9A) - MEGAHIT
echo "Launching Job 11A: QUAST"
JOBID11A=$(bsub -J "$JOB11A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB11A_CPUS \
    -q $JOB11A_QUEUE \
    -R "rusage[mem=$JOB11A_MEMORY]" \
    -M $JOB11A_MEMORY \
    -W $JOB11A_TIME \
    -w "done($JOBID9A)" \
    -o "${QUAST_LOGS_O_MEGA}/megahit_quast.11A.%J_%I.log" \
    -e "${QUAST_LOGS_E_MEGA}/megahit_quast.11A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB11A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 11A array with ID $JOBID11A"

# Job 11B: QUAST (depends on 9B) - metaSPAdes
echo "Launching Job 11B: QUAST"
JOBID11B=$(bsub -J "$JOB11B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB11B_CPUS \
    -q $JOB11B_QUEUE \
    -R "rusage[mem=$JOB11B_MEMORY]" \
    -M $JOB11B_MEMORY \
    -W $JOB11B_TIME \
    -w "done($JOBID9B)" \
    -o "${QUAST_LOGS_O_META}/metaspades_quast.11B.%J_%I.log" \
    -e "${QUAST_LOGS_E_META}/metaspades_quast.11B.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB11B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 11B array with ID $JOBID11B"

# Job 12A: CheckM2 (depends on 9A1, runs concurrently with 9B/9C) MEGAHIT
echo "Launching Job 12A: CheckM2"
JOBID12A=$(bsub -J "$JOB12A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB12A_CPUS \
    -q $JOB12A_QUEUE \
    -R "rusage[mem=$JOB12A_MEMORY]" \
    -M $JOB12A_MEMORY \
    -W $JOB12A_TIME \
    -w "done($JOBID9A)" \
    -o "${CHECKM_LOGS_O_MEGA}/megahit_checkm.12A.%J_%I.log" \
    -e "${CHECKM_LOGS_E_MEGA}/megahit_checkm.12A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB12A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 12A array with ID $JOBID12A"

# Job 12B: CheckM2 (depends on 9A2, runs concurrently with 9B/9C) metaSPAdes
echo "Launching Job 12B: CheckM2"
JOBID12B=$(bsub -J "$JOB12B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB12B_CPUS \
    -q $JOB12B_QUEUE \
    -R "rusage[mem=$JOB12B_MEMORY]" \
    -M $JOB12B_MEMORY \
    -W $JOB12B_TIME \
    -w "done($JOBID9B)" \
    -o "${CHECKM_LOGS_O_META}/metaspades_checkm.12B.%J_%I.log" \
    -e "${CHECKM_LOGS_E_META}/metaspades_checkm.12B.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB12B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 12B array with ID $JOBID12B"

# Job 13: Read Taxonomy (depends on 05, runs independently)
echo "Launching Job 13: Read Taxonomy"
JOBID13=$(bsub -J "$JOB13[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB13_CPUS \
    -q $JOB13_QUEUE \
    -R "rusage[mem=$JOB13_MEMORY]" \
    -M $JOB13_MEMORY \
    -W $JOB13_TIME \
    -w "done($JOBID5)" \
    -o "${READ_TAX_LOGS_O}/read_taxonomy.13.%J_%I.log" \
    -e "${READ_TAX_LOGS_E}/read_taxonomy.13.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB13}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 13 array with ID $JOBID13"

# Job 14A: Contig Taxonomy (depends on 7A) MEGAHIT
echo "Launching Job 14A: Contig Taxonomy"
JOBID14A=$(bsub -J "$JOB14A[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB14A_CPUS \
    -q $JOB14A_QUEUE \
    -R "rusage[mem=$JOB14A_MEMORY]" \
    -M $JOB14A_MEMORY \
    -W $JOB14A_TIME \
    -w "done($JOBID7A)" \
    -o "${CONTIG_TAX_LOGS_O}/contig_taxonomy.14A.%J_%I.log" \
    -e "${CONTIG_TAX_LOGS_E}/contig_taxonomy.14A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB14A}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 14A array with ID $JOBID14A"

# Job 14B: Contig Taxonomy (depends on 7A) metaSPAdes
echo "Launching Job 14B: Contig Taxonomy"
JOBID14B=$(bsub -J "$JOB14B[1-$NUM_JOB]%$NUM_JOB" \
    -n $JOB14B_CPUS \
    -q $JOB14B_QUEUE \
    -R "rusage[mem=$JOB14B_MEMORY]" \
    -M $JOB14B_MEMORY \
    -W $JOB14B_TIME \
    -w "done($JOBID7B)" \
    -o "${CONTIG_TAX_LOGS_O}/contig_taxonomy.14A.%J_%I.log" \
    -e "${CONTIG_TAX_LOGS_E}/contig_taxonomy.14A.%J_%I.err" \
    < $RUN_SCRIPTS/${JOB14B}.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 14B array with ID $JOBID14B"

# --- End Workflow Steps ---
echo ""
echo "All jobs submitted successfully!"
echo "Pipeline flow (A=MEGAHIT, B=metaSPAdes):"
echo "  1 → 2 → 3 → 4 → 5 → (7A & 7B) -> (14A & 14B)"
echo "              ↓           ↓       "
echo "              6       (8A & 8B)"
echo "              ↓            ↓"
echo "              13      (9A & 9B) → (10) → (11A & 11B)"
echo "                          ↓"
echo "                      (12A & 12B)"
