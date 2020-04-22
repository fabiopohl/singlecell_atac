#' Create SNAP file from CellRanger output
#' 
#' @param 
#' @return

from snakemake.shell import shell

# Get inputs and parameters
bam_file = snakemake.input.bam
print(bam_file)
# extract the header file
sample_name = bam_file[:-4]
print(sample_name)
shell("samtools view {bam_file} -H > {sample_name}.header.sam")

# create a bam file with the barcode embedded into the read name
#shell(
#    """cat <( cat {sample_name}.header.sam ) 
#    <( samtools view {bam_file} | 
#    awk '{for (i=12; i<=NF; ++i) { if ($i ~ "^CB:Z:"){ td[substr($i,1,2)] = substr($i,6,length($i)-5); } }; printf "%s:%s\\n", td["CB"], $0 }' ) |  
#    samtools view -bS - > {sample_name}.snap.bam"""
#)
shell(
"cat <( cat {sample_name}.header.sam ) "
"<( samtools view {bam_file} | awk '{{for (i=12; i<=NF; ++i) {{ if ($i ~ \"^CB:Z:\"){{ td[substr($i,1,2)] = substr($i,6,length($i)-5); }} }}; printf \"%s:%s\\n\", td[\"CB\"], $0 }}' ) "
"| samtools view -bS - > {sample_nshme}.snap.bam"
)

# Sort bam file
shell("samtools sort -n -@ 10 -m 1G {sample_name}.snap.bam -o {sample_name}.snap.nsrt.bam")

# Generate snap file
shell(
        """snaptools snap-pre  
	--input-file={sample_name}.snap.nsrt.bam  
	--output-snap={sample_name}.snap  
        --genome-name=hg38 
        --genome-size=/Users/fabiopohl/proj/human_fetal_atac/hg38.chrom.sizes 
	--min-mapq=30  
	--min-flen=50  
	--max-flen=1000  
	--keep-chrm=TRUE  
	--keep-single=FALSE  
	--keep-secondary=False  
	--overwrite=True  
	--max-num=20000  
	--min-cov=500  
	--verbose=True"""
)

