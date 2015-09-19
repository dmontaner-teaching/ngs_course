% NGS data analysis tutorial: <br> RNA-Seq Analysis using Cufflinks
% [Estudios in silico en Biomedicina](http://www.uv.es/bioinfor/) <br> _Máster en Bioinformática, Universidad de Valencia_
% [David Montaner](http://www.dmontaner.com) <br> _2014-11-25_


<!-- COMMON LINKS HERE -->

[bowtie2]:http://bowtie-bio.sourceforge.net/bowtie2/index.shtml "Bowtie2 home page"
[tophat]:http://ccb.jhu.edu/software/tophat/index.shtml "TopHat home page"
[samtools]:http://samtools.sourceforge.net "SAMtools home"

[cufflinks]:http://cufflinks.cbcb.umd.edu/index.html "Cufflinks hokme page"
[cuffdiff]:http://cufflinks.cbcb.umd.edu/manual.html#cuffdiff "CUffdiff section of Cufflinks"

[gtf]:http://www.ensembl.org/info/website/upload/gff.html "General Feature Format"
[sam]:http://samtools.sourceforge.net/SAMv1.pdf "SAM/BAM formats"


Preliminaries
================================================================================

Software used in this practical:
--------------------------------

- [Bowtie2] and [TopHat] alignment tools.
- [Cuffdiff] module of [Cufflinks] that allows for the analysis of differential expression.


File formats explored:
----------------------

- [SAM/BAM][sam]:
- [GTF]: General Feature Format.


Overview
================================================================================

1. We use [tophat] to align RNA-Seq reads to the refference genome.
1. We use Cuffdiff (Cufflinks) to perform a differential expression analysis of RNA-Seq data.


Exercise
================================================================================

Create an empty directory to work in the exercise and copy or download the raw data to it.
You will need to copy the __reference genome__ the __GTF annotation file__ and the _paired end_ fastq files of the 3 samples (6 files in total).

    cd data

<!-- data_test directory to run my examples
    cd ..
    rm -r data_test
    mkdir data_test
    cp data/* data_test/
	cd data_test
-->


Map against the reference genome using bowtie2
--------------------------------------------------------------------------------

Fist we need to __build an index__ for bowtie:

    bowtie2-build f000_chr21_ref_genome_sequence.fa f001_bowtie_index


And now we can run the __alignments__ for the __paired end__ files:

	tophat2 -r 300 -o f021_case_tophat_out   f001_bowtie_index   f011_case_read1.fastq f011_case_read2.fastq
	tophat2 -r 300 -o f022_case_tophat_out   f001_bowtie_index   f012_case_read1.fastq f012_case_read2.fastq
	tophat2 -r 300 -o f023_case_tophat_out   f001_bowtie_index   f013_case_read1.fastq f013_case_read2.fastq

	tophat2 -r 300 -o f024_cont_tophat_out   f001_bowtie_index   f014_cont_read1.fastq f014_cont_read2.fastq
	tophat2 -r 300 -o f025_cont_tophat_out   f001_bowtie_index   f015_cont_read1.fastq f015_cont_read2.fastq
	tophat2 -r 300 -o f026_cont_tophat_out   f001_bowtie_index   f016_cont_read1.fastq f016_cont_read2.fastq

__REMARK:__ For __paired end__ samples the left and the right files have to be separated using an __space__.  
If separated by a __coma__, tophat understands the two files contain reads form the same sample sequenced in a __single end__ protocol.



Convert BAM files to SAM format
--------------------------------------------------------------------------------

Use [samtools] to convert the BAM files to a SAM (text file) format: 

    samtools view -h f021_case_tophat_out/accepted_hits.bam > f031_case.sam
	samtools view -h f022_case_tophat_out/accepted_hits.bam > f032_case.sam
	samtools view -h f023_case_tophat_out/accepted_hits.bam > f033_case.sam

    samtools view -h f024_cont_tophat_out/accepted_hits.bam > f034_cont.sam
	samtools view -h f025_cont_tophat_out/accepted_hits.bam > f035_cont.sam
	samtools view -h f026_cont_tophat_out/accepted_hits.bam > f036_cont.sam

<!--
this step does not seem necessary any more
-->

As the alignment files are now in text format, 
we can use the Linux shell command `wc` to estimate the number of aligned reads in each sample.

    wc -l *.sam

- Why does it seem that the control samples do have more aligned reads? 
  Count also the number of reads in each sample (fastq files)
  
<!-- 
    wc -l *.fastq
-->


Differential expression using Cuffdiff
--------------------------------------------------------------------------------

Now that the alignments are done we can use `cufdiff` to perform a differential expression analysis.

In this step the software will make use of the __GTF file__ `f005_chr21_genome_annotation.gtf`. 
This file contains the annotation of the features (genes, transcripts, ...) of interest in our study. 


Compare 2 samples:
	
    cuffdiff -o f040_dif_exp_two f005_chr21_genome_annotation.gtf   f031_case.sam   f034_cont.sam

Compare several samples:

    cuffdiff -o f040_dif_exp_several f005_chr21_genome_annotation.gtf   f031_case.sam,f032_case.sam,f033_case.sam   f034_cont.sam,f035_cont.sam,f036_cont.sam

Explore the results.  
You can find an explanation of the at <http://cufflinks.cbcb.umd.edu/manual.html#cuffdiff_output>


<!-- 

cufflinks -o g040_salida_cufflinks -G f005_chr21_genome_annotation.gtf f031_case.sam
	
cuffdiff -o f041_dif_exp_two f005_chr21_genome_annotation.gtf   f021_case_tophat_out/accepted_hits.bam   f024_cont_tophat_out/accepted_hits.bam


Understanding the results
--------------------------------------------------------------------------------

-->
