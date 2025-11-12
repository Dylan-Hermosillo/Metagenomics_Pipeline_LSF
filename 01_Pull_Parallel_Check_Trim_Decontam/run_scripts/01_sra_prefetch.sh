#!/bin/bash
# -------------------------
# 01_SRA_PREFETCH.sh - a script to generate wrappers to prefetch READS_DIR datasets and run them in parallel
# -------------------------

# --- Housekeeping ---
pwd; hostname; date
source ./config.sh

# --- Get the dataset for this job ---
JOBINDEX=$(($LSB_JOBINDEX - 1))
datasets=($(cat ${XFILE}))
DATA_PATH=${datasets[${JOBINDEX}]}

echo "Processing dataset: $DATA_PATH on `date`"
XFILE=$(basename "$DATA_PATH")

# --- Generate Wrapper ---
# For example READS_DIR Prefetch using Apptainer
if [[ ! -f "$READS_DIR/$XFILE/${XFILE}.READS_DIR" ]]; then
    echo "Generating READS_DIR Prefetch wrapper for $XFILE"
fasterq-dump -e $JOB2_CPUS --split-files $NAME -O $READS_DIR/$NAME
    # Wrapper script content
    COMMAND1="mkdir -p ${READS_DIR}/${XFILE}"
    COMMAND2="${APPT} exec --bind ${READS_DIR}:${READS_DIR} ${SRA_TOOLKIT} prefetch ${XFILE} -O ${READS_DIR} > ${SRA_OUT}/${XFILE}_prefetch.log 2> ${SRA_ERR}/${DATA_N>
    COMMAND3="${APPT} exec --bind ${READS_DIR}:${READS_DIR} ${SRA_TOOLKIT} fasterq-dump ${XFILE} -O ${READS_DIR}/${XFILE} --split-files > ${SRA_OUT}/${XFILE}_fasterq.log 2> ${SRA_ERR}/${XFILE}_fasterq.err"
    # Write wrapper file
    echo "$COMMAND1" > "${WRAP_SCRIPTS}/${XFILE}_prefetch_wrapper.sh"
    echo "$COMMAND2" >> "${WRAP_SCRIPTS}/${XFILE}_prefetch_wrapper.sh"
    chmod 755 "${WRAP_SCRIPTS}/${XFILE}_prefetch_wrapper.sh"

    # Append to aggregate for GNU Parallel
    echo "${WRAP_SCRIPTS}/${XFILE}_prefetch_wrapper.sh" >> "${SCRIPTS_DIR}/aggregate_prefetch_wrappers.txt"
fi
