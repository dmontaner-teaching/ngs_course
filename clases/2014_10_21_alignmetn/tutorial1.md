% NGS data analysis tutorial: <br> Alignment
% [Estudios in silico en Biomedicina](http://www.uv.es/bioinfor/) <br> _Máster en Bioinformática, Universidad de Valencia_
% [David Montaner](http://www.dmontaner.com) <br> _2014-10-21_

<!-- Common URLs: Tools -->

[bwa]:http://bio-bwa.sourceforge.net/ "Burrows-Wheeler Aligner"

<!-- Common URLs: File Formats -->

[sam]:http://samtools.github.io/hts-specs/SAMv1.pdf "http://samtools.github.io/hts-specs/SAMv1.pdf"

<!-- External URLs -->


Preliminaries
================================================================================

Software used in this practical:
----------------------------------------

- [BWA] : Burrows-Wheeler Aligner. A software package for mapping low-divergent sequences against a large reference genomes.

File formats explored in this practical:
----------------------------------------

- [SAM] : Sequence Alignment/Map format. A TAB-delimited text format storing the alignment information. A _header section_ is optional.  
  Mandatory fields are: 
    1. QNAME: read name
    2.  FLAG: bitwise FLAG
    3. RNAME: reference sequence name (chromosome)
    4.   POS: 1-based leftmost mapping position (where the read starts mapping)
    5.  MAPQ: mapping quality
    6. CIGAR: CIGAR string
    7. RNEXT: name of the mate/next read (for paired ends)
    8. PNEXT: Position of the mate/next read  (BP O )
    9.  TLEN: observed Template LENgth
    10.  SEQ: read sequence
    11. QUAL: read quality (phred-scale +33)


Data used in this practical:
-------------------------------

- __f000_chr21_ref_genome_sequence.fa__: reference genome. For the practical we will just use the 21 human chromosome.
- s010_reads.fastq: reads form a _single end_ experiment (simulated form chr21)
- p010_reads1.fastq, p010_reads2.fastq: reads from a _paired end_ experiment (simulated form chr21)


Overview
================================================================================


1. Index the reference genome using `bwa index`
1. Map the _single end_ reads and explore the output [SAM] file.
1. Map the _paired ends_ reads and explore the output [SAM] file.


Exercise
================================================================================

Create an empty directory to work in the exercise and copy or download the raw data to it: 

    cd data

<!-- data_test directory to run my examples
    cd .. 
    rm -r data_test
    mkdir data_test
    cp data/*fa data_test
    cp data/*fastq data_test
    cd data_test
-->


Exploring the reference genome
--------------------------------------------------------------------------------

Explore our reference genome file: `f000_chr21_ref_genome_sequence.fa`

- How many chromosomes are there?

    grep "^>" f000_chr21_ref_genome_sequence.fa

- How long is the sequence in base pairs?

You can find this out just by counting the number of letters in the sequence.
You can use the shell command `wc` to achieve that ...
but bear in mind that `wc -m` will include in the count the __newline__ characters;
you will have to subtract the number of lines to the number of characters. 

    grep -v "^>" f000_chr21_ref_genome_sequence.fa | wc -l -m

- What does the option `-v` does in the command above?

<!-- 
48932060 - 802165 = 48129895
-->


Exploring the read files
--------------------------------------------------------------------------------

- How many reads do we have in our experiment?

You can count the number of reads in the files ...

    wc -l *fastq

and divide by four. Why?

- Do the names of the paired end files match?

_Grep_ the ids and compare the two files:

    grep "^@" p010_reads1.fastq
    grep "^@" p010_reads2.fastq 


Indexing the reference genome
--------------------------------------------------------------------------------

The first step when using [BWA] is to _index_ the our reference: 

    bwa index -a bwtsw f000_chr21_ref_genome_sequence.fa 

This step will take around one minute. 

- What does it mean the option `-a bwtsw`?
  (Find out the help of the command by typing `bwa index` in the shell)

<!--
Warning:
`-a bwtsw' does not work for short genomes, while `-a is' and
`-a div' do not work not for long genomes. Please choose `-a' according to the length of the genome.
-->

- How many new files have been crated in the working directory?
- How are they called?
- What are they?


Single end Reads Alignment
--------------------------------------------------------------------------------

Once the index has been created, 
the alignment of single end reads is done in __two steps__ using [BWA].

First we use the `aln` option to create an _intermediate_ file with the extension __sai__: 

    bwa aln -f s020_reads.sai f000_chr21_ref_genome_sequence.fa s010_reads.fastq 

- What is the option `-f` intended for?
- What happens if you do not set it?

Then we can finish our mapping and get a [SAM] file using the option `samse` (see indicates single ends).

    bwa samse -f s030_reads.sam -r "@RG\tID:sample1" f000_chr21_ref_genome_sequence.fa s020_reads.sai s010_reads.fastq 

- What is the `-r` parameter? (revise the [SAM] specification)
- What happens if you do not include it?
- What happens if you do not format properly this line? ... type for instance `-r "sample1"`

Explore the header of the created [SAM] file:

    head s030_reads.sam

<!-- 
@SQ	SN:21	LN:48129895
@RG	ID:sample1
@PG	ID:bwa	PN:bwa	VN:0.7.10-r789	CL:bwa samse -f s030_reads.sam -r @RG\tID:sample1 f000_chr21_ref_genome_sequence.fa s020_reads.sai s010_reads.fastq
-->

<!-- 
@SQ : "Reference sequence dictionary"
@RG : "Read group"
@PG : "Program" that did the alignment
-->

- Which information is in the `@SQ` line?
- What does the `LN` information math our estimated length of the 21 chromosome?
- How many `@SQ` lines would we have if we had more than one chromosome?
  Create a fake reference with more chromosomes and repeat the mapping in order to explore this. 
- Has the _Read group_ line (`@RG`) the information you did include?
- Can yo find out the specifications of the program which did create the alignment?


Explore the alignment section of the file.



Paired end Reads Alignment
--------------------------------------------------------------------------------

The alignment of paired ends files is done in __two steps__ with [BWA].

As before we use the `aln` option. This step is done separately with each of the fastq files:

    bwa aln -f p020_reads1.sai f000_chr21_ref_genome_sequence.fa p010_reads1.fastq
	bwa aln -f p020_reads2.sai f000_chr21_ref_genome_sequence.fa p010_reads2.fastq 


In the paired end case we will use the option `sampe` to combine the two __sai__ files into a unique [SAM] file:

    bwa sampe -f p030_reads.sam -r "@RG\tID:sample1" f000_chr21_ref_genome_sequence.fa p020_reads1.sai p020_reads2.sai p010_reads1.fastq p010_reads2.fastq 

Explore the output [SAM] file.

