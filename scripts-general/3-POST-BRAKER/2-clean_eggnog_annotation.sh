#!/bin/bash

OUT=~/lustre/eggnog_LEUVEN_clean_skip4

mkdir -p ${OUT}

for SAMPLE in $(cat <samples_file>)
do

 tail -n +5 ~/lustre/eggnog_LEUVEN/${SAMPLE}/${SAMPLE}_eggnog.emapper.annotations | sed 's/#//g' > ${OUT}/${SAMPLE}_eggnog.emapper.annotations_clean

done
