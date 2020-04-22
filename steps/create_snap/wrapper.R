#' Create SNAP file from CellRanger output
#' 
#' @param 
#' @return

# Get inputs and parameters
bam_file <- snakemake@input[["bam"]]

# extract the header file
sample_name <- gsub(".bam", "", bam_file)
cmd <- paste0(c(" view ", bam_file, " -H > ", sample_name, ".header.sam"), collapse = "")

#system2(samtools view atac_v1_adult_brain_fresh_5k_possorted_bam.bam -H > atac_v1_adult_brain_fresh_5k_possorted.header.sam)
system2("samtools", cmd)

# create a bam file with the barcode embedded into the read name
cmd_cat <- paste0(c(" <( ", sample_name, ".header.sam ) <( samtools view ", bam_file,
                    "| awk \'{for (i=12; i<=NF; ++i) { if ($i ~ \"^CB:Z:\"){ td[substr($i,1,2)] = substr($i,6,length($i)-5); } }; printf \"%s:%s\\n\", td[\"CB\"], $0 }\' ) ",
                    "samtools view -bS - > ", sample_name, ".snap.bam"), collapse = "")

system2("cat", cmd_cat) 

cat <( cat atac_v1_adult_brain_fresh_5k_possorted.header.sam ) \
<( samtools view atac_v1_adult_brain_fresh_5k_possorted_bam.bam | awk '{for (i=12; i<=NF; ++i) { if ($i ~ "^CB:Z:"){ td[substr($i,1,2)] = substr($i,6,length($i)-5); } }; printf "%s:%s\n", td["CB"], $0 }' ) \
| samtools view -bS - > atac_v1_adult_brain_fresh_5k_possorted.snap.bam

# Testing
bam_file <- "possorted_bam.bam"
