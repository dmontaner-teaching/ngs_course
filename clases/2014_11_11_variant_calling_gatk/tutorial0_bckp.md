% NGS data analysis tutorial: <br> Variant Calling with GATK
% [Estudios in silico en Biomedicina](http://www.uv.es/bioinfor/) <br> _Máster en Bioinformática, Universidad de Valencia_
% [David Montaner](http://www.dmontaner.com) <br> _2014-11-11_


<!-- Common URLs: Tools -->

[bwa]:http://bio-bwa.sourceforge.net/ "Burrows-Wheeler Aligner"
[samtools]:http://samtools.sourceforge.net/ "SAMtools old site"
[samtools-new]:http://www.htslib.org/ "SAMtools new site"

[samtools-man]:http://samtools.sourceforge.net/samtools.shtml "SAMtools online manual"

[bcftools]:http://samtools.sourceforge.net/samtools.shtml#4  "BCFtools online manual (section of the SAMtools online manual)"

[igv]:http://www.broadinstitute.org/igv/ "Integrative Genomics Viewer home page"


[SAMstat]:http://sourceforge.net/projects/samstat/ "SAMstat home page"


<!-- Common URLs: File Formats -->

[sam]:http://samtools.github.io/hts-specs/SAMv1.pdf   "SAM/BAM specification"
[vcf]:http://samtools.github.io/hts-specs/VCFv4.2.pdf "VCF specification"

[allformats]:https://github.com/samtools/hts-specs  "SAM/BAM and VCF actual specifications"

[sam-sum]:http://samtools.sourceforge.net/samtools.shtml#5   "SAM format summary"
[vcf-sum]:http://samtools.sourceforge.net/samtools.shtml#6   "VCF format summary"


<!-- External URLs -->



Preliminaries
================================================================================

Software used in this practical:
----------------------------------------

- [SAMtools] : Samtools is a suite of programs for interacting with high-throughput sequencing data; mostly with SAM/BAM.
  Find the manual page [here][samtools-man].
- [bcftools] : Part of the SAMtools suit for handling BCF files
- [IGV] : Integrative Genomics Viewer
- [SAMstat] : some statistics of the mapped reads.



- [SAMTools] : SAM Tools provide various utilities for manipulating alignments in the SAM format, including sorting, merging, indexing and generating alignments in a per-position format.
- [Picard] : Picard comprises Java-based command-line utilities that manipulate SAM files, and a Java API (SAM-JDK) for creating new programs that read and write SAM files.
- [GATK] : Genome Analysis Toolkit - A package to analyse next-generation re-sequencing data, primary focused on variant discovery and genotyping.




File formats explored in this practical:
----------------------------------------

- [SAM/BAM][SAM] : Sequence Alignment/Map format. A TAB-delimited text format storing the alignment information. A _header section_ is optional. BAM is the binary format.  
  See [SAM format summary][sam-sum]
- [VCF] : Variant Calling Format  
  See [VCF format summary][vcf-sum]
- __pileup__ : Is an intermediate file format generated by `samtools mpileup` to store variant information.  
  [See samtools mpileup description](http://samtools.sourceforge.net/samtools.shtml#3)
- __BCF__ : binary call format a binary version of the __pileup__ file format.



- [SAM](http://samtools.sourceforge.net/SAMv1.pdf)
- [BAM](http://www.broadinstitute.org/igv/bam)
- VCF Variant Call Format: see [1000 Genomes](http://www.1000genomes.org/wiki/analysis/variant-call-format/vcf-variant-call-format-version-42) and [Wikipedia](http://en.wikipedia.org/wiki/Variant_Call_Format) specifications.





Data used in this practical:
----------------------------------------

- __s050_sorted.bam__ : the BAM file generated using [BWA] in the previous sessions. It has been sorted using [SAMtools].
- __f000_chr21_ref_genome_sequence.fa__ : the reference genome.


Overview
================================================================================

- We will use [SAMstat] to get some statistics of our alignment.
- We will use `samtools` to get a VCF file of our data.


Exercise 1: Variant calling with paired-end data
================================================================================

Retrieve the __s050_sorted.bam__ file generated in the previous practices.

    cd data

<!-- data_test directory to run my examples
    cd ..
    rm -r data_test
    mkdir data_test
    cp data/000-dna_chr21_100_hq_pe.bam        data_test
    cp data/f000_chr21_ref_genome_sequence.fa  data_test
	cd data_test
-->



Exercise 1: 
================================================================================

Copy the necessary data in your working directory:

    mkdir -p /home/participant/cambridge_mda14/
    cp -r /home/participant/Desktop/Open_Share/calling /home/participant/cambridge_mda14/
    cd /home/participant/cambridge_mda14/calling

These datasets contain reads only for the __chromosome 21__.


1. Prepare reference genome: generate the fasta file index
--------------------------------------------------------------------------------
Enter in the genome directory:

    cd genome

Use ``SAMTools`` to generate the fasta file index:

    samtools faidx f000_chr21_ref_genome_sequence.fa

This creates a file called samtools faidx f000_chr21_ref_genome_sequence.fa.fai, with one record per line for each of the contigs in the FASTA reference file.


Generate the sequence dictionary using ``Picard``:

    java -jar ../picard/CreateSequenceDictionary.jar REFERENCE=f000_chr21_ref_genome_sequence.fa OUTPUT=f000_chr21_ref_genome_sequence.dict


2. Prepare BAM file
--------------------------------------------------------------------------------

Go to the example1 folder:

    cd /home/participant/cambridge_mda14/calling/example1

<!-- The __read group__ information is key for downstream GATK functionality. The GATK will not work without a read group tag. Make sure to enter as much metadata as you know about your data in the read group fields provided. For more information about all the possible fields in the @RG tag, take a look at the SAM specification.

    AddOrReplaceReadGroups.jar I=f000-dna_100_high_pe.bam O=f010-dna_100_high_pe_fixRG.bam RGID=group1 RGLB=lib1 RGPL=illumina RGSM=sample1 RGPU=unit1

-->

We must sort and index the BAM file before processing it with Picard and GATK. To sort the bam file we use ``samtools``

    samtools sort 000-dna_chr21_100_hq_pe.bam 001-dna_chr21_100_hq_pe_sorted

Index the BAM file:

    samtools index 001-dna_chr21_100_hq_pe_sorted.bam


3. Mark duplicates (using Picard)
--------------------------------------------------------------------------------

Run the following __Picard__ command to mark duplicates:

    java -jar ../picard/MarkDuplicates.jar INPUT=001-dna_chr21_100_hq_pe_sorted.bam OUTPUT=002-dna_chr21_100_hq_pe_sorted_noDup.bam METRICS_FILE=002-metrics.txt

This creates a sorted BAM file called ``002-dna_chr21_100_hq_pe_sorted_noDup.bam`` with the same content as the input file, except that any duplicate reads are marked as such. It also produces a metrics file called ``metrics.txt`` containing (can you guess?) metrics.

__QUESTION:__ How many reads are removed as duplicates from the files (hint view the on-screen output from the two commands)?

Run the following __Picard__ command to index the new BAM file:

    java -jar ../picard/BuildBamIndex.jar INPUT=002-dna_chr21_100_hq_pe_sorted_noDup.bam


4. Local realignment around INDELS (using GATK)
--------------------------------------------------------------------------------

There are 2 steps to the realignment process:

__First__, create a target list of intervals which need to be realigned
  
    java -jar ../gatk/GenomeAnalysisTK.jar -T RealignerTargetCreator -R ../genome/f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_pe_sorted_noDup.bam -o 003-indelRealigner.intervals

__Second__, perform realignment of the target intervals

    java -jar ../gatk/GenomeAnalysisTK.jar -T IndelRealigner -R ../genome/f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_pe_sorted_noDup.bam -targetIntervals 003-indelRealigner.intervals -o 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam

This creates a file called ``003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam`` containing all the original reads, but with better local alignments in the regions that were realigned.


5. Base quality score recalibration (using GATK)
--------------------------------------------------------------------------------

Two steps:

__First__, analyse patterns of covariation in the sequence dataset

    java -jar ../gatk/GenomeAnalysisTK.jar -T BaseRecalibrator -R ../genome/f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam -knownSites ../000-dbSNP_chr21.vcf -o 004-recalibration_data.table

This creates a GATKReport file called ``004-recalibration_data.table`` containing several tables. These tables contain the covariation data that will be used in a later step to recalibrate the base qualities of your sequence data.

It is imperative that you provide the program with a set of __known sites__, otherwise it will refuse to run. The known sites are used to build the covariation model and estimate empirical base qualities. For details on what to do if there are no known sites available for your organism of study, please see the online GATK documentation.

__Second__, apply the recalibration to your sequence data

    java -jar ../gatk/GenomeAnalysisTK.jar -T PrintReads -R ../genome/f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam -BQSR 004-recalibration_data.table -o 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam

This creates a file called ``004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam`` containing all the original reads, but now with exquisitely accurate base substitution, insertion and deletion quality scores. By default, the original quality scores are discarded in order to keep the file size down. However, you have the option to retain them by adding the flag ``–emit_original_quals`` to the ``PrintReads`` command, in which case the original qualities will also be written in the file, tagged OQ.


6. Variant calling (using GATK - __UnifiedGenotyper__)
--------------------------------------------------------------------------------

SNPs and INDELS are called using separate instructions.

__SNP calling__

    java -jar ../gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -R ../genome/f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam -glm SNP -o 005-dna_chr21_100_he_pe_snps.vcf

__INDEL calling__

    java -jar ../gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -R ../genome/f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam -glm INDEL -o 005-dna_chr21_100_hq_pe_indel.vcf


7. Introduce filters in the VCF file
--------------------------------------------------------------------------------

Example: filter SNPs with low confidence calling (QD < 12.0) and flag them as "LowConf".

    java -jar ../gatk/GenomeAnalysisTK.jar -T VariantFiltration -R ../genome/f000_chr21_ref_genome_sequence.fa -V 005-dna_chr21_100_he_pe_snps.vcf --filterExpression "QD < 12.0" --filterName "LowConf" -o 006-dna_chr21_100_he_pe_snps_filtered.vcf

The command ``--filterExpression`` will read the INFO field and check whether variants satisfy the requirement. If a variant does not satisfy your filter expression, the field FILTER will be filled with the indicated ``--filterName``. These commands can be called several times indicating different filtering expression (i.e: --filterName One --filterExpression "X < 1" --filterName Two --filterExpression "X > 2").

__QUESTION:__ How many "LowConf" variants have we obtained?

    grep LowConf 006-dna_chr21_100_he_pe_snps_filtered.vcf | wc -l
