#!/bin/bash

####################
### remove all soft clipped reads
####################

# Adjustable threshold for total soft-clipped bases
THRESHOLD=1

# Input directory containing BAM files
INPUT_DIR="/home/barrientosm/projects/GE2POP/2024_TRANS_CWR/2024_MANUEL_BARRIENTOS/02_results/BAM_cleaned/speltoides/speltoides_TrEx"

# Output directory for filtered BAM files
OUTPUT_DIR="/home/barrientosm/projects/GE2POP/2024_TRANS_CWR/2024_MANUEL_BARRIENTOS/02_results/BAM_cleaned/speltoides/speltoides_TrEx/Bams_no_soft_clipped_reads"



# Loop over all BAM files in the input directory that don't have 'bai' in their names
for INPUT_BAM in "$INPUT_DIR"/*.bam; do
    # Skip files with 'bai' in their names
    if [[ "$INPUT_BAM" == *"bai"* ]]; then
        continue
    fi
    
    # Get the base name of the file (without the path)
    BASE_NAME=$(basename "$INPUT_BAM" .bam)
    
    # Set the output file path
    OUTPUT_BAM="$OUTPUT_DIR/${BASE_NAME}_20_soft_clipped_reads.bam"
    
    # Perform filtering
    samtools view -h "$INPUT_BAM" | \
    awk -v threshold="$THRESHOLD" 'BEGIN {
        FS = "\t";
        OFS = "\t";
    }
    {
        if ($6 ~ /S/) {
            soft_start = 0;
            soft_end = 0;
            if (match($6, /^([0-9]+)S/, arr)) {
                soft_start = arr[1];
            }
            if (match($6, /([0-9]+)S$/, arr)) {
                soft_end = arr[1];
            }
            total_soft = soft_start + soft_end;
            
            # Skip reads with a total soft-clipped bases > threshold
            if (total_soft >= threshold) next;
        }
        print $0;
    }' | samtools view -bS - > "$OUTPUT_BAM"
    
    echo "Filtered BAM file saved to $OUTPUT_BAM"
done
