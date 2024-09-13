#!/bin/sh

#SBATCH --account=x
#SBATCH --job-name=concatenate
#SBATCH --cpus-per-task=2
#SBATCH --ntasks-per-node=1
#SBATCH --output=data/logs/concatenate_%A_%a.out
#SBATCH --error=data/logs/concatenate_%A_%a.err
#SBATCH --array=1-x%x

SAMPLES_FILE=<samples_file>
SAMPLE=$(cat ${SAMPLES_FILE} | awk "NR == ${SLURM_ARRAY_TASK_ID}")
DATA_DIR="data/clean/trimgalore"
OUT_DIR='data/clean/concatenate'

# concatenate

cat ${DATA_DIR}/${SAMPLE}*_1.fq.gz > ${OUT_DIR}/${SAMPLE}_1.fq.gz
cat ${DATA_DIR}/${SAMPLE}*_2.fq.gz > ${OUT_DIR}/${SAMPLE}_2.fq.gz
