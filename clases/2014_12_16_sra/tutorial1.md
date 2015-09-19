% NGS data analysis tutorial: <br> Public repositories of NGS data
% [Estudios in silico en Biomedicina](http://www.uv.es/bioinfor/) <br> _Máster en Bioinformática, Universidad de Valencia_
% [David Montaner](http://www.dmontaner.com) <br> _2014-12-16_


<!-- COMMON LINKS HERE -->

[geo]:http://www.ncbi.nlm.nih.gov/geo/ "Gene Expression Omnibus"

[sra]:http://www.ncbi.nlm.nih.gov/sra/ "Sequence Read Archive database at the NCBI"
[sra toolkit]:http://www.ncbi.nlm.nih.gov/Traces/sra/?view=software "SRA Toolkit"
[sra toolkit docs]:http://www.ncbi.nlm.nih.gov/Traces/sra/?view=toolkit_doc "SRA Toolkit Documentation"

[samtools]:http://samtools.sourceforge.net/ "SAMtools home"

[fastqc]:http://www.bioinformatics.babraham.ac.uk/projects/fastqc "FastQC home page"


Preliminaries
================================================================================

In this practical we will
download one of the samples provided in the paper from
Lau et al. (2013) [Alteration of the microRNA network during the progression of Alzheimer's disease][lau-2013],
and use the [SRA Toolkit] to convert it to __fastq__ and __BAM__ formats.

[lau-2013]:http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3799583 "Lau et al. (2013)"

Software used in this practical:
--------------------------------

- [SRA Toolkit] : tools for reading (dumping) and writing sequencing files from [SRA] database.
- [SAMtools] : utilities on manipulating alignments in the SAM format.


__Note__:

When installing the [SRA Toolkit] you can use the `md5sum` Shell command to verify that the binary file has been properly downloaded.
Find the _md5 checksums_ file in the [SRA Toolkit web page][SRA Toolkit]


[sra toolkit]:http://www.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=software "reading and writing files from the SRA database"


File formats explored:
----------------------

- __SRA__: compressed binary format.
- SAM / BAM
- FastQ


Overview
================================================================================

1. Find trace the data location through the [GEO] and [SRA] web sites.
1. Extract read data in __fastq__ and __SAM/BAM__ formats.


Exercise
================================================================================

According to [Lau et al. (2013)][lau-2013]:

> The data obtained from the 12 libraries have been submitted  
> to the GEO database under accession number [GSE48552](http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE48552).

Go to the [GEO] web page and find the dataset _(GEO series)_. 
See how the _Supplementary file links_ drive you to the [SRA] data base.

Follow the links and find the file called __SRR1103937.sra__. 

Which kind of data are available in this file?

What does it mean the nomenclature `SRP/SRP026/SRP026562` in the GEO web page?
How does it relates to the SRA FTP site?



Extract data in fastq format
--------------------------------------------------------------------------------

Once you have downloaded one _.sra_ file 
you can use the _SRA Toolkit_ to extract the original reads and their qualities in fastq format:

    fastq-dump SRR1103937.sra

- How many reads are their in this file?
- How big is the SRA file? And the FASATQ file?
- Use [FastQC] to explore data quality.

<!--
wc -l SRR1103937.fastq  ## 62 639 152 SRR1103937.fastq
fastqc SRR1103937.fastq
-->

But the _SRA Toolkit_ also allows you reading the _.sra_ file directly form the __FTP__ site by simply using the file ID:

    fastq-dump SRR926292

- Explore the downloading options typing `fastq-dump --help`
- Can you download compressed formats?



Extract data in SAM format
--------------------------------------------------------------------------------

The _SRA Toolkit_ allows you to get the _SAM_ file of the _run_:

    sam-dump SRR1103937.sra > mysamfile.sam
	
And now you can use [SAMtools] to handle the file, for instance to convert it into a _BAM_ file:

	samtools view -Sb mysamfile.sam -o mysamfile.bam

You can perform the two previous steps at a time using the pipe operator `|`:

    sam-dump SRR1103937.sra | samtools view -Sb mysamfile.sam -o mysamfile.bam 

`sam-dump` may also be used to access remote data using the file ID:

    sam-dump SRR1103937 | head 

- How many aligned reads are there in the sample?
  <!-- cut -f 2 mysamfile.sam | uniq  ## solo 4 -->


<!-- ---------------------------------------------------------------------------
You may want _sam-dump_ to include SAM headers:

    sam-dump --header SRR1103937.sra > mysamfile_with_header.sam


Or to include your own text into the header:

    sam-dump --header-comment 'THIS IS MY CUSTOM TEXT' SRR1103937.sra > mysamfile_with_custom_header.sam

But watch out for the software the version: 

    sam-dump --version
------------------------------------------------------------------------------->
