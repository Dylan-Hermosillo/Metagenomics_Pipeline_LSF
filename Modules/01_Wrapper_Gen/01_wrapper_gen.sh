#!/bin/bash
#BSUB -R "span[hosts=1]"
#BSUB -o "${WRAP_LOGS_O}/wrapper.gen.%J.%I.log" \
#BSUB -e "${WRAP_LOGS_E}/wrapper.gen.%J.%I.err" \

# -------------------------
# 01_wrapper_gen.sh - a script to generate wrappers to prefetch READS_DIR dataset and run them in parallel
# -------------------------

# --- Housekeeping ---
pwd; hostname; date
source ./config.sh

# --- Get the dataset for this job ---
JOBINDEX=$(($LSB_JOBINDEX - 1))
datasets=($(cat ${XFILE}))
DATA_PATH=${datasets[${JOBINDEX}]}

echo "Processing dataset: $DATA_PATH on `date`"
DATA_NAME=$(basename "$DATA_PATH")

# --- Generate Wrapper ---
if [[ ! -f "$READS_DIR/${DATA_NAME}/${DATA_NAME}.READS_DIR" ]]; then
    echo "Generating READS_DIR Prefetch wrapper for $DATA_NAME"
    # Wrapper script content
    COMMAND1="mkdir -p ${READS_DIR}/${DATA_NAME}"
    COMMAND2="${APPT} exec --bind ${READS_DIR}:${READS_DIR} ${SRA_TOOLKIT} prefetch ${DATA_NAME} -O ${READS_DIR} -c > ${SRA_LOGS_O}/${DATA_NAME}_prefetch.log 2> ${SRA_LOGS_E}/${DATA_NAME}_prefetch.err"
    COMMAND3="${APPT} exec --bind ${READS_DIR}:${READS_DIR} ${SRA_TOOLKIT} fasterq-dump ${DATA_NAME} -O ${READS_DIR}/${DATA_NAME}/${DATA_NAME} --split-files --temp ${READS_DIR}/${DATA_NAME} > ${SRA_LOGS_O}/${DATA_NAME}_fasterq.log 2> ${SRA_LOGS_E}/${DATA_NAME}_fasterq.err"
    # Write wrapper file
    echo "$COMMAND1" > "${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh"
    echo "$COMMAND2" >> "${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh"
    echo "$COMMAND3" >> "${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh"
    chmod 755 "${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh"

    # Append to aggregate for GNU Parallel
    echo "${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh" >> "${RUN_SCRIPTS}/aggregate_prefetch_wrappers.txt"
fi
