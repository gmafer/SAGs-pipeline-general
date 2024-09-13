#!/bin/bash

#SBATCH --time=1-12:00:00
#SBATCH --job-name=braker
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=10GB
#SBATCH --output=data/logs/braker_%A_%a.out
#SBATCH --error=data/logs/braker_%A_%a.err
#SBATCH --array=1-x%x

# DOWNLOAD DATABASE !!!!! IT HAS SPACES IN HEADERS, DONT REMOEVE THEM
# wget  https://bioinf.uni-greifswald.de/bioinf/partitioned_odb11/Eukaryota.fa.gz

# REMEMBER REMOVE /home/csic/eyg/gmf/store/config/species/orthodb_P*

module load cesga/2020 gcc/system braker/2.1.6

SAMPLE=$(cat <samples file> | awk "NR == ${SLURM_ARRAY_TASK_ID}")

AA_DIR=~/lustre/braker/aa/
COD_DIR=~/lustre/braker/codingseq/
GTF_DIR=~/lustre/braker/gtf/
LOG_DIR=~/lustre/braker/logs

mkdir -p ${AA_DIR}
mkdir -p ${COD_DIR}
mkdir -p ${GTF_DIR}
mkdir -p ${LOG_DIR}

SPECIES=${SAMPLE}

GENOME=~/store/spades_essentials/scaffolds/${SAMPLE}_K127_scaffolds.fasta

DB=${STORE}/Eukaryota.fa

#########
######### CHECK $LUSTRE_SCRATCH ls /mnt/lustre/scratch/nvme/SLURM/
#########

cd $LUSTRE_SCRATCH
mkdir -p ${SPECIES}
cd ${SPECIES}

# GeneMark's default contig length is >50kb
# Practically no SAG has contigs this long
# I change it here with flag `--min_contig`

module load seqkit

CONTIGS_10K=$(seqkit seq -m 10000 ${GENOME} | grep -c '^>')
CONTIGS_5K=$(seqkit seq -m 5000 ${GENOME} | grep -c '^>')
CONTIGS_2K=$(seqkit seq -m 2000 ${GENOME} | grep -c '^>')

if (( ${CONTIGS_10K} > 100 ))
then 
    MIN_CONTIG=10000
elif (( ${CONTIGS_5K} > 100 ))
then
    MIN_CONTIG=5000
elif (( ${CONTIGS_2K} > 100 ))
then
    MIN_CONTIG=2000
else
    MIN_CONTIG=1000
fi

braker.pl \
  --min_contig=${MIN_CONTIG} \
  --species=orthodb_${SPECIES} \
  --genome=${GENOME} \
  --AUGUSTUS_CONFIG_PATH=/home/csic/eyg/gmf/store/config/ \
  --AUGUSTUS_BIN_PATH=/opt/cesga/2020/software/Compiler/gcc/system/augustus/3.4.0/bin/ \
  --prot_seq=${DB}

cp ${LUSTRE_SCRATCH}/${SPECIES}/braker/augustus.hints.aa ${AA_DIR}/${SPECIES}_augustus.hints.aa
cp ${LUSTRE_SCRATCH}/${SPECIES}/braker/augustus.hints.codingseq ${COD_DIR}/${SPECIES}_augustus.hints.codingseq
cp ${LUSTRE_SCRATCH}/${SPECIES}/braker/augustus.hints.gtf ${GTF_DIR}/${SPECIES}_augustus.hints.gtf
cp ${LUSTRE_SCRATCH}/${SPECIES}/braker/braker.log ${LOG_DIR}/${SPECIES}_braker.log
