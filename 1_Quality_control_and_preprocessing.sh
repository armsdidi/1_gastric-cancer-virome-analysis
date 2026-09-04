#!/bin/bash

#PBS -l select=1:ncpus=24
#PBS -l walltime=36:00:00
#PBS -N diego_fastp
#PBS -V
#PBS -j oe
#PBS -o diego_fastp_report

# Activating the conda environment on the server:
source activate bioinfo

# Creating the main directories:
BASE_DIR="/scratch/LABIOINF/dpereira"
RAW_DIR="/scratch/LABIOINF/dpereira/samples/raw_fastq"
CLEAN_DIR="/scratch/LABIOINF/dpereira/samples/clean_fastq"

# Performing quality control with FASTP:
echo ">>> Removing adapters and low-quality reads (QV ≥ 15)..."
for sample in ${RAW_DIR}/*_1.fastq; do
    base=$(basename "$sample" _1.fastq)
    echo "Processing $base..."

    fastp \
        -i ${RAW_DIR}/${base}_1.fastq \
        -I ${RAW_DIR}/${base}_2.fastq \
        -o ${CLEAN_DIR}/${base}.R1.clean.fastq.gz \
        -O ${CLEAN_DIR}/${base}.R2.clean.fastq.gz \
        --detect_adapter_for_pe \
        --qualified_quality_phred 15 \
        --length_required 50 \
        --thread 8 \
        --html ${CLEAN_DIR}/${base}.fastp.html \
        --json ${CLEAN_DIR}/${base}.fastp.json \
        --report_title "fastp report for ${base}"
done

# Removing temporary files:
cd $RAW_DIR

echo ">>> Removing temporary files..."
rm *.fastq.gz

echo ">>> Quality control completed successfully!"