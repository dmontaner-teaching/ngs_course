% NGS data analysis tutorial: <br> Variant Calling with GATK
% [Estudios in silico en Biomedicina](http://www.uv.es/bioinfor/) <br> _Máster en Bioinformática, Universidad de Valencia_
% [David Montaner](http://www.dmontaner.com) <br> _2014-11-11_

<!-- COMMON LINKS HERE -->

[SAMTools]: http://samtools.sourceforge.net/ "samtools"
[Picard]: http://picard.sourceforge.net/ "Picard"
[GATK]: http://www.broadinstitute.org/gatk/ "GATK"

Preliminaries
================================================================================

Software used in this practical:
--------------------------------

- [SAMTools] : SAM Tools provide various utilities for manipulating alignments in the SAM format, including sorting, merging, indexing and generating alignments in a per-position format.
- [Picard] : Picard comprises Java-based command-line utilities that manipulate SAM files, and a Java API (SAM-JDK) for creating new programs that read and write SAM files.
- [GATK] : Genome Analysis Toolkit - A package to analyse next-generation re-sequencing data, primary focused on variant discovery and genotyping.


__Note on Picard__

In this tutorial we asume you did install Picard using `apt-get`.
Then you will be able to call `picard-tools` from your shell.

If you have a custom installation of Picard then you will need to call it via Java doing something like: 

    java -jar ../picard/CreateSequenceDictionary.jar

instead of

    picard-tools CreateSequenceDictionary


see [here](https://github.com/biocosas/ngs_software_installation/blob/master/picard.md) for picard installation.

__GATK__

Depending on your installation of GATK. You may run it typing

    GATK

or you will need to execute it via Java. Then the call will be similar to: 

    java -jar ../gatk/GenomeAnalysisTK.jar

see [here](https://github.com/biocosas/ngs_software_installation/blob/master/gatk.md) for GATK installation.


File formats explored:
----------------------

- [SAM](http://samtools.sourceforge.net/SAMv1.pdf)
- [BAM](http://www.broadinstitute.org/igv/bam)
- VCF Variant Call Format: see [1000 Genomes](http://www.1000genomes.org/wiki/analysis/variant-call-format/vcf-variant-call-format-version-42) and [Wikipedia](http://en.wikipedia.org/wiki/Variant_Call_Format) specifications.


Exercise 1: Variant calling with paired-end data 
================================================================================

In this practical we will find variants in the paired-end BAM file `000-dna_chr21_100_hq_pe.bam`.
We will need the `f000_chr21_ref_genome_sequence.fa` reference file used when mapping the reads and creating the BAM file. 
We will also need a file describing the _known variant sites_ 000-dbSNP_chr21.vcf. This will be used in the recalibration steps.

These datasets contain reads only for the **chromosome 21**.

Copy the necessary data in your working directory:

    cd data

<!-- data_test directory to run my examples
    cd ..
    rm -r data_test
    mkdir data_test
    cp data/f000_chr21_ref_genome_sequence.fa data_test
    cp data/000-dna_chr21_100_hq_se.bam       data_test
    cp data/000-dna_chr21_100_hq_pe.bam       data_test 
    cp data/000-dbSNP_chr21.vcf               data_test
    cd data_test
-->


1. Prepare reference genome: generate the fasta file index
--------------------------------------------------------------------------------

Use ``SAMTools`` to generate the fasta file index:

    samtools faidx f000_chr21_ref_genome_sequence.fa

This creates a file called samtools faidx f000_chr21_ref_genome_sequence.fa.fai, with one record per line for each of the contigs in the FASTA reference file.


Generate the sequence dictionary using ``Picard``:

    ##java -jar ../picard/CreateSequenceDictionary.jar REFERENCE=f000_chr21_ref_genome_sequence.fa OUTPUT=f000_chr21_ref_genome_sequence.dict
    picard-tools CreateSequenceDictionary REFERENCE=f000_chr21_ref_genome_sequence.fa OUTPUT=f000_chr21_ref_genome_sequence.dict


2. Prepare BAM file
--------------------------------------------------------------------------------

<!--
The **read group** information is key for downstream GATK functionality.
The GATK will not work without a read group tag.
Make sure to enter as much metadata as you know about your data in the read group fields provided.
For more information about all the possible fields in the @RG tag, take a look at the SAM specification.

    AddOrReplaceReadGroups.jar I=f000-dna_100_high_pe.bam O=f010-dna_100_high_pe_fixRG.bam RGID=group1 RGLB=lib1 RGPL=illumina RGSM=sample1 RGPU=unit1
-->

We must sort and index the BAM file before processing it with Picard and GATK. To sort the bam file we use ``samtools``

    samtools sort 000-dna_chr21_100_hq_pe.bam 001-dna_chr21_100_hq_pe_sorted

Index the BAM file:

    samtools index 001-dna_chr21_100_hq_pe_sorted.bam


3. Mark duplicates (using Picard)
--------------------------------------------------------------------------------

Run the following **Picard** command to mark duplicates:

    ##java -jar ../picard/MarkDuplicates.jar INPUT=001-dna_chr21_100_hq_pe_sorted.bam OUTPUT=002-dna_chr21_100_hq_pe_sorted_noDup.bam METRICS_FILE=002-metrics.txt
	picard-tools MarkDuplicates INPUT=001-dna_chr21_100_hq_pe_sorted.bam OUTPUT=002-dna_chr21_100_hq_pe_sorted_noDup.bam METRICS_FILE=002-metrics.txt

This creates a sorted BAM file called ``002-dna_chr21_100_hq_pe_sorted_noDup.bam`` with the same content as the input file,
except that any duplicate reads are marked as such. It also produces a metrics file called ``metrics.txt`` containing (can you guess?) metrics.

**QUESTION:** How many reads are removed as duplicates from the files (hint view the on-screen output from the two commands)?

Run the following **Picard** command to index the new BAM file:

    ##java -jar ../picard/BuildBamIndex.jar INPUT=002-dna_chr21_100_hq_pe_sorted_noDup.bam
	picard-tools BuildBamIndex INPUT=002-dna_chr21_100_hq_pe_sorted_noDup.bam


4. Local realignment around INDELS (using GATK)
--------------------------------------------------------------------------------

There are 2 steps to the realignment process:

**First**, create a target list of intervals which need to be realigned
  
    ##java -jar ../gatk/GenomeAnalysisTK.jar -T RealignerTargetCreator -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_pe_sorted_noDup.bam -o 003-indelRealigner.intervals
	GATK -T RealignerTargetCreator -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_pe_sorted_noDup.bam -o 003-indelRealigner.intervals

**Second**, perform realignment of the target intervals

    ##java -jar ../gatk/GenomeAnalysisTK.jar -T IndelRealigner -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_pe_sorted_noDup.bam -targetIntervals 003-indelRealigner.intervals -o 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam
	GATK -T IndelRealigner -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_pe_sorted_noDup.bam -targetIntervals 003-indelRealigner.intervals -o 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam


This creates a file called ``003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam`` containing all the original reads, but with better local alignments in the regions that were realigned.


5. Base quality score recalibration (using GATK)
--------------------------------------------------------------------------------

Two steps:

**First**, analyse patterns of covariation in the sequence dataset

    ##java -jar ../gatk/GenomeAnalysisTK.jar -T BaseRecalibrator -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam -knownSites ../000-dbSNP_chr21.vcf -o 004-recalibration_data.table
	GATK -T BaseRecalibrator -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam -knownSites 000-dbSNP_chr21.vcf -o 004-recalibration_data.table

This creates a GATKReport file called ``004-recalibration_data.table`` containing several tables. These tables contain the covariation data that will be used in a later step to recalibrate the base qualities of your sequence data.

It is imperative that you provide the program with a set of **known sites**, otherwise it will refuse to run. The known sites are used to build the covariation model and estimate empirical base qualities. For details on what to do if there are no known sites available for your organism of study, please see the online GATK documentation.

**Second**, apply the recalibration to your sequence data

    ##java -jar ../gatk/GenomeAnalysisTK.jar -T PrintReads -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam -BQSR 004-recalibration_data.table -o 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam
    GATK -T PrintReads -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam -BQSR 004-recalibration_data.table -o 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam

This creates a file called ``004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam`` containing all the original reads,
but now with exquisitely accurate base substitution, insertion and deletion quality scores.
By default, the original quality scores are discarded in order to keep the file size down.
However, you have the option to retain them by adding the flag ``–emit_original_quals`` to the ``PrintReads`` command,
in which case the original qualities will also be written in the file, tagged OQ.


6. Variant calling (using GATK - **UnifiedGenotyper**)
--------------------------------------------------------------------------------

SNPs and INDELS are called using separate instructions.

**SNP calling**

    ##java -jar ../gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam -glm SNP -o 005-dna_chr21_100_he_pe_snps.vcf
	GATK -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam -glm SNP -o 005-dna_chr21_100_he_pe_snps.vcf

**INDEL calling**

    ##java -jar ../gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam -glm INDEL -o 005-dna_chr21_100_hq_pe_indel.vcf
	GATK -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam -glm INDEL -o 005-dna_chr21_100_hq_pe_indel.vcf


7. Introduce filters in the VCF file
--------------------------------------------------------------------------------

Example: filter SNPs with low confidence calling (QD < 12.0) and flag them as "LowConf".

    ##java -jar ../gatk/GenomeAnalysisTK.jar -T VariantFiltration -R f000_chr21_ref_genome_sequence.fa -V 005-dna_chr21_100_he_pe_snps.vcf --filterExpression "QD<12.0" --filterName "LowConf" -o 006-dna_chr21_100_he_pe_snps_filtered.vcf
	GATK -T VariantFiltration -R f000_chr21_ref_genome_sequence.fa -V 005-dna_chr21_100_he_pe_snps.vcf --filterExpression "QD<12.0" --filterName "LowConf" -o 006-dna_chr21_100_he_pe_snps_filtered.vcf

The command ``--filterExpression`` will read the INFO field and check whether variants satisfy the requirement. If a variant does not satisfy your filter expression, the field FILTER will be filled with the indicated ``--filterName``. These commands can be called several times indicating different filtering expression (i.e: --filterName One --filterExpression "X < 1" --filterName Two --filterExpression "X > 2").

- How many "LowConf" variants have we obtained?

    grep LowConf 006-dna_chr21_100_he_pe_snps_filtered.vcf | wc -l

- What happen if you include some white spaces into the filter expression? <!-- some error is returned ->

    --filterExpression "QD < 12.0"



Exercise 2: Variant calling with single-end data
================================================================================

Go to the exercise2 folder in your course directory: 

    cd /home/participant/cambridge_mda14/calling/example2


1. Prepare reference genome: generate the fasta file index
--------------------------------------------------------------------------------

This step is no longer needed since we have already done it in [example1](http://ngs-course.github.io/Course_Materials/variant_calling/tutorial/010_example.html)

2. Prepare BAM file
--------------------------------------------------------------------------------

We must sort the BAM file using ``samtools``:

    samtools sort 000-dna_chr21_100_hq_se.bam 001-dna_chr21_100_hq_se_sorted

Index the BAM file:

    samtools index 001-dna_chr21_100_hq_se_sorted.bam


3. Mark duplicates (using Picard)
--------------------------------------------------------------------------------

Mark and remove duplicates:

    java -jar ../picard/MarkDuplicates.jar INPUT=001-dna_chr21_100_hq_se_sorted.bam OUTPUT=002-dna_chr21_100_hq_se_sorted_noDup.bam METRICS_FILE=002-metrics.txt

Index the new BAM file:

    java -jar ../picard/BuildBamIndex.jar INPUT=002-dna_chr21_100_hq_se_sorted_noDup.bam


4. Local realignment around INDELS (using GATK)
--------------------------------------------------------------------------------

There are 2 steps to the realignment process:

Create a target list of intervals which need to be realigned
  
    java -jar ../gatk/GenomeAnalysisTK.jar -T RealignerTargetCreator -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_se_sorted_noDup.bam -o 003-indelRealigner.intervals

Perform realignment of the target intervals:

    java -jar ../gatk/GenomeAnalysisTK.jar -T IndelRealigner -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_se_sorted_noDup.bam -targetIntervals 003-indelRealigner.intervals -o 003-dna_chr21_100_hq_se_sorted_noDup_realigned.bam


5. Base quality score recalibration (using GATK)
--------------------------------------------------------------------------------

Two steps:

Analyze patterns of covariation in the sequence dataset

    java -jar ../gatk/GenomeAnalysisTK.jar -T BaseRecalibrator -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_se_sorted_noDup_realigned.bam -knownSites ../000-dbSNP_chr21.vcf -o 004-recalibration_data.table

Apply the recalibration to your sequence data

    java -jar ../gatk/GenomeAnalysisTK.jar -T PrintReads -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_se_sorted_noDup_realigned.bam -BQSR 004-recalibration_data.table -o 004-dna_chr21_100_hq_se_sorted_noDup_realigned_recalibrated.bam


6. Variant calling (using GATK - **UnifiedGenotyper**)
--------------------------------------------------------------------------------

**SNP calling**

    java -jar ../gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_se_sorted_noDup_realigned_recalibrated.bam -glm SNP -o 005-dna_chr21_100_hq_se_snps.vcf

**INDEL calling**

    java -jar ../gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_se_sorted_noDup_realigned_recalibrated.bam -glm INDEL -o 005-dna_chr21_100_hq_se_indel.vcf


7. Compare paired-end VCF against single-end VCF
--------------------------------------------------------------------------------

Open IGV and load a the paired-end VCF we have generated in the previous tutorial (``005-dna_chr21_100_he_pe_snps.vcf``), its corresponding original BAM file (``001-dna_chr21_100_hq_pe_sorted.bam``) and the processed BAM (``004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam``).
