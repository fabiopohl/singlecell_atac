#' Create SNAP file from CellRanger output
#' 
#' @param 
#' @return

# Get inputs and parameters
bam_file <- snakemake@input[["bam"]]

# extract the header file
samtools_path <- ""
cmd <- paste(list("view", bam_file, "-H >",

system2(samtools view atac_v1_adult_brain_fresh_5k_possorted_bam.bam -H > atac_v1_adult_brain_fresh_5k_possorted.header.sam)

# create a bam file with the barcode embedded into the read name
cat <( cat atac_v1_adult_brain_fresh_5k_possorted.header.sam ) \
<( samtools view atac_v1_adult_brain_fresh_5k_possorted_bam.bam | awk '{for (i=12; i<=NF; ++i) { if ($i ~ "^CB:Z:"){ td[substr($i,1,2)] = substr($i,6,length($i)-5); } }; printf "%s:%s\n", td["CB"], $0 }' ) \
| samtools view -bS - > atac_v1_adult_brain_fresh_5k_possorted.snap.bam
