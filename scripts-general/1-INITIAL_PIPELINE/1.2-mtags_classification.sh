#!/bin/sh

#SBATCH --account=x
#SBATCH --job-name=classification
#SBATCH --cpus-per-task=24
#SBATCH --ntasks-per-node=1
#SBATCH --output=data/logs/classify_%J.out
#SBATCH --error=data/logs/classify_%J.err 

# mTags classification

# Load modules

module load usearch/9.2.64
module load python/3.8.5

# Files and paths

DATA_DIR='data/mtags'
DB='../04-Databases/eukaryotesV4_v5/eukaryotesV4_v5.fasta'
OUT_TABLE='data/'
OUT_MAP='data/uc_files'
OUT_NAME='easig_sags'
MTAGS_CONSENSUS_TAXONOMY=../03-Scripts/scripts_sags/mtags_consensus_tax_v2.py # python script to filter map
MAKE_OTU_TABLE=../03-Scripts/scripts_sags/make_otu_table.py # python script to create OTU table
FASTA=${DATA_DIR}/${OUT_NAME}_mtags.fasta

# Concatenate

cat ${DATA_DIR}/*mtags.fna > ${FASTA}

# Top hits map

usearch \
-usearch_local ${FASTA} \
-db ${DB} \
-uc ${OUT_MAP}/${OUT_NAME}_tophits.uc \
-id 0.97 \
-mincols 105 \ #original was 70
-strand both \
-top_hits_only \
-maxaccepts 0 \
-maxrejects 0 \
-threads 24

# Make consensus taxonomy

${MTAGS_CONSENSUS_TAXONOMY} \
  --tax_separator '_' \
  --tax_sense 'asc' \
  --pair_separator '/' \
  --output_file ${OUT_MAP}/${OUT_NAME}.uc \
  ${OUT_MAP}/${OUT_NAME}_tophits.uc

# Make otu table

${MAKE_OTU_TABLE} \
  --sample_identifier 'barcodelabel=' \
  --output_file ${OUT_TABLE}/${OUT_NAME}_otuTable.txt \
  ${OUT_MAP}/${OUT_NAME}.uc
