#!/bin/bash

#SBATCH --time=24:00:00
#SBATCH --job-name=spades12
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=100GB
#SBATCH --output=data/logs/spades_%J.out
#SBATCH --error=data/logs/spades_%J.err
#SBATCH --array=1-x%x

module load spades

DATA_DIR='~/lustre/sags/'

SAMPLE=$(cat <samples_file> | awk "NR == ${SLURM_ARRAY_TASK_ID}")

OUT_DIR=~/lustre/data/clean/assembly/${SAMPLE}

mkdir -p ${OUT_DIR}

NUM_THREADS=24

spades.py \
 -1 ${DATA_DIR}/${SAMPLE}_R1_001_val_1.fq.gz \
 -2 ${DATA_DIR}/${SAMPLE}_R2_001_val_2.fq.gz \
 -t ${NUM_THREADS} \
 -m 100 \
 --sc \
 -k 21,33,55,77,99,127 \
 -o ${OUT_DIR}
