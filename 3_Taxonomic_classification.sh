#!/bin/bash

#PBS -l select=1:ncpus=24
#PBS -l walltime=36:00:00
#PBS -N diego_kraken2
#PBS -V
#PBS -j oe
#PBS -o diego_kraken2_report

# Activating the conda environment on the server:
source activate bioinfo

# Creating the main directories:
BASE_DIR="/scratch/LABIOINF/dpereira"
SAMPLES_DIR="$BASE_DIR/samples/nonhuman_fastq"
REP_DIR="$BASE_DIR/viral_reports"
REF_DIR="$BASE_DIR/databases/virus_db"

# Creating a list of samples:
cd "$SAMPLES_DIR"

echo ">>> Creating a list of samples..."
ls *.nonhuman_R1.fastq.gz \
    | sed 's/.nonhuman_R1.fastq.gz//' \
    | sort -u > "$BASE_DIR/all_sample.txt"

# Performing taxonomic classification:
echo ">>> Starting classification with Kraken2..."

while read -r SAMPLE; do

    echo "===================================="
    echo " → Processing: $SAMPLE"
    echo "===================================="

    kraken2 \
        --threads 20 \
        --db "$REF_DIR" \
        --report "$REP_DIR/${SAMPLE}.report" \
        --use-names \
        --paired \
        "$SAMPLES_DIR/${SAMPLE}.nonhuman_R1.fastq.gz" \
        "$SAMPLES_DIR/${SAMPLE}.nonhuman_R2.fastq.gz"

done < "$BASE_DIR/all_sample.txt"

echo ">>> Taxonomic classification completed successfully!"
