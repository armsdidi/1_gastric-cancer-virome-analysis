#!/bin/bash

#PBS -l select=1:ncpus=24
#PBS -l walltime=36:00:00
#PBS -N diego_kraken2
#PBS -V
#PBS -j oe
#PBS -o diego_kraken2_report

# Activating the Conda environment on the server:
source activate bioinfo

# Creating the main directories:
BASE_DIR="/scratch/LABIOINF/dpereira"
SAMPLES_DIR="$BASE_DIR/samples/clean_fastq"
REP_DIR="$BASE_DIR/viral_reports"
REF_DIR="$BASE_DIR/databases/virus_db"

# Creating a list of samples:
cd $SAMPLES_DIR

echo ">>> Creating a list of samples..."
ls *.R1.clean.fastq.gz \
    | sed 's/.R1.clean.fastq.gz//' \
    | sort -u > "$BASE_DIR/all_sample.txt"

# Performing taxonomic classification:
echo ">>> Starting classification with Kraken2..."

while read -r SAMPLE; do
    echo " → Processando: $SAMPLE"

    kraken2 \
    --threads 20 \
    --db "$REF_DIR" \
    --report "$REP_DIR/${SAMPLE}.report" \
    --use-names \
    --paired \
    "$SAMPLES_DIR/${SAMPLE}.R1.clean.fastq.gz" \
    "$SAMPLES_DIR/${SAMPLE}.R2.clean.fastq.gz"

done < "$BASE_DIR/all_sample.txt"

echo ">>> Taxonomic classification completed successfully!"
