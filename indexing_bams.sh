#!/bin/bash

module load bioinfo-cirad
module load samtools/1.14-bin


#### 
# indew bams files with samtools
########

for bam in *.bam; do
    echo "Indexing $bam"
    samtools index "$bam"
done
