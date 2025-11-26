#!/bin/bash

# Parse FastQC warnings/failures from before and after trimming
# Usage: ./parse_fastqc_warnings.sh

source ./config.sh

# Function to parse FastQC zips for a directory
parse_fastqc_dir() {
    local DIR=$1
    local STAGE=$2
    local REPORT_FILE=$3
    
    echo "FastQC Warnings and Failures Report" > $REPORT_FILE
    echo "Generated: $(date)" >> $REPORT_FILE
    echo "Stage: $STAGE" >> $REPORT_FILE
    echo "========================================" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    
    for zip in $DIR/*/*.zip; do
        if [[ -f "$zip" ]]; then
            # Extract sample name and read number
            filename=$(basename $zip .zip)
            
            # Determine sample name and read pair
            if [[ $filename =~ _1_fastqc$ ]]; then
                sample=$(echo $filename | sed 's/_1_fastqc$//')
                read_pair="R1"
            elif [[ $filename =~ _2_fastqc$ ]]; then
                sample=$(echo $filename | sed 's/_2_fastqc$//')
                read_pair="R2"
            else
                sample=$(echo $filename | sed 's/_fastqc$//')
                read_pair="Unknown"
            fi
            
            # Extract warnings and failures
            warnings=$(unzip -p $zip */summary.txt 2>/dev/null | grep -E "WARN|FAIL")
            
            if [[ -n "$warnings" ]]; then
                echo "Sample: $sample | Read: $read_pair" >> $REPORT_FILE
                echo "$warnings" | awk '{print "  " $1 " - " $2}' >> $REPORT_FILE
                echo "" >> $REPORT_FILE
            fi
        fi
    done
    
    echo "" >> $REPORT_FILE
    echo "Summary for $STAGE:" >> $REPORT_FILE
    echo "  Total WARN: $(grep -c "WARN" $REPORT_FILE)" >> $REPORT_FILE
    echo "  Total FAIL: $(grep -c "FAIL" $REPORT_FILE)" >> $REPORT_FILE
}

# Parse before trimming (Step 3)
REPORT_BEFORE="${FASTQC_BEFORE}/fastqc_warnings_report.txt"
parse_fastqc_dir "$FASTQC_BEFORE" "BEFORE TRIMMING (Step 3)" "$REPORT_BEFORE"
echo "Report generated: $REPORT_BEFORE"

# Parse after trimming (Step 6)
REPORT_AFTER="${FASTQC_AFTER}/fastqc_warnings_report.txt"
parse_fastqc_dir "$FASTQC_AFTER" "AFTER TRIMMING (Step 6)" "$REPORT_AFTER"
echo "Report generated: $REPORT_AFTER"
