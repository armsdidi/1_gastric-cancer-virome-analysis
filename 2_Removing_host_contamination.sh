#!/bin/bash

#PBS -l select=1:ncpus=24
#PBS -l walltime=36:00:00
#PBS -N diego_human_removal
#PBS -V
#PBS -j oe
#PBS -o diego_human_removal_report

# Activating the conda environment:
source /sw/apps/python/anaconda3-2024-10-1/etc/profile.d/conda.sh
conda activate /home/dpereira/bioinfo_env

# Creating the main directories:
BASE_DIR="/scratch/LABIOINF/dpereira"
CLEAN_DIR="$BASE_DIR/samples/clean_fastq"
NONHUMAN_DIR="$BASE_DIR/samples/nonhuman_fastq"
ALIGN_DIR="$BASE_DIR/human_alignment"
REF_DIR="$BASE_DIR/reference/hg38"
BOWTIE_INDEX="$REF_DIR/hg38"

# Creating the sample list:
cd "$CLEAN_DIR"

echo ">>> Creating sample list..."

ls *.R1.clean.fastq.gz \
    | sed 's/.R1.clean.fastq.gz//' \
    | sort -u > "$BASE_DIR/all_sample.txt"

# Starting human read removal:
echo ">>> Starting human read removal..."

while read -r SAMPLE; do

    echo "===================================="
    echo " → Processing: $SAMPLE"
    echo "===================================="

    # Aligning reads against the human genome and retaining unmapped paired-end reads:
    echo ">>> Aligning reads against the human genome..."

    bowtie2 \
        -x "$BOWTIE_INDEX" \
        -1 "$CLEAN_DIR/${SAMPLE}.R1.clean.fastq.gz" \
        -2 "$CLEAN_DIR/${SAMPLE}.R2.clean.fastq.gz" \
        -p 24 \
        --very-sensitive \
        --un-conc-gz "$NONHUMAN_DIR/${SAMPLE}.nonhuman.fastq.gz" \
        -S "$ALIGN_DIR/${SAMPLE}.human.sam"

    # Removing the SAM file:
    rm "$ALIGN_DIR/${SAMPLE}.human.sam"

    # Renaming unmapped paired-end reads:
    mv "$NONHUMAN_DIR/${SAMPLE}.nonhuman.fastq.1.gz" \
       "$NONHUMAN_DIR/${SAMPLE}.nonhuman_R1.fastq.gz"

    mv "$NONHUMAN_DIR/${SAMPLE}.nonhuman.fastq.2.gz" \
       "$NONHUMAN_DIR/${SAMPLE}.nonhuman_R2.fastq.gz"

    echo " → Completed: $SAMPLE"
    echo "===================================="

done < "$BASE_DIR/all_sample.txt"

echo ">>> Human read removal completed successfully!"