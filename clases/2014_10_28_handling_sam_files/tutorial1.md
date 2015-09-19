% NGS data analysis tutorial: <br> Handling SAM/BAM files
% [Estudios in silico en Biomedicina](http://www.uv.es/bioinfor/) <br> _Máster en Bioinformática, Universidad de Valencia_
% [David Montaner](http://www.dmontaner.com) <br> _2014-10-28_

<!-- Common URLs: Tools -->

[bwa]:http://bio-bwa.sourceforge.net/ "Burrows-Wheeler Aligner"
[samtools]:http://samtools.sourceforge.net/ "SAMtools old site"
[samtools-new]:http://www.htslib.org/ "SAMtools new site"

[samtools-man]:http://www.htslib.org/doc/samtools-1.1.html "SAMtools manual (version 1.1)"

[igv]:http://www.broadinstitute.org/igv/ "Integrative Genomics Viewer home page"


<!-- Common URLs: File Formats -->

[sam]:http://samtools.github.io/hts-specs/SAMv1.pdf "http://samtools.github.io/hts-specs/SAMv1.pdf"


<!-- External URLs -->


Preliminaries
================================================================================

Software used in this practical:
----------------------------------------

- [SAMtools] : Samtools is a suite of programs for interacting with high-throughput sequencing data; mostly with SAM/BAM.
  Find the manual page [here][samtools-man].
- [IGV] : Integrative Genomics Viewer


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
- [BAM] : A __binary__ version of the SAM file.


Data used in this practical:
----------------------------------------

- __s030_reads.sam__ the SAM file generated using [BWA] in the previous sessions. 


Overview
================================================================================

1. Explore the SAM file using [SAMtools]
1. Sort alignments in chromosome order
1. Index the file.
1. Visualize the alignment using [IGV]


Exercise
================================================================================

Retrieve the __s030_reads.sam__ file generated in the last practical.

    cd data

<!-- data_test directory to run my examples
    cd .. 
    rm -r data_test
    mkdir data_test
    cp s030_reads.sam
-->


Explore the SAM file
--------------------------------------------------------------------------------

We can use `samtools view` to access some parts of the file. 

We can for instance get the header of the file doing 

    samtools view -SH s030_reads.sam

The alignment of the SAM file may be accessed doing

    samtools view -S s030_reads.sam

Notice that this command does not include the __header__ lines 

    samtools view -S s030_reads.sam | head 

You can include those with the option `-h`

    samtools view -Sh s030_reads.sam | head 


- What does it mean the option `-S` used in all commands above?  
  (find the documentation at `samtools view -?`)
- What happens if you do not include the `-S` option in the command? 


Binary (BAM) version of the file
--------------------------------------------------------------------------------

Generally we do not want to handle text files.

We can convert SAM files to binary __and compressed__ format BAM using `samtools view`

    samtools view -Sb -o s040_reads.bam s030_reads.sam

Check that the file has been compressed

    ls -lh 

and that is a binary file

    head s040_reads.bam

You can specifically find the file formats using the shell function `file`

    file *

which will return the specification of each file.


\  


We can recover (or visualize) the information in the BAM file using `samtools view` again

    samtools view s040_reads.bam

- Does this file have the header lines?
  ```samtools view s040_reads.bam | head```
- Is it then a valid BAM file?


Usually we may prefer to use BAM files which include the __header__ lines so that no information is lost. 

We can go from the SAM file to BAM version keeping the header using the option `-h` already explored above

    samtools view -Sbh -o s040_reads_and_head.bam s030_reads.sam

Check that the header is there now

<!-- 
    samtools -h view s040_reads_and_head.bam | head

or 

    samtools view -H s040_reads_and_head.bam
-->


Filtering the alignments by FLAG
--------------------------------------------------------------------------------

We can use `samtools view` to filter the reads according to their FLAG.

For exploratory purposes we could extract the FLAG column using `samtools`
and the shell command `cut`.
We know form the specification of the SAM/BAM file
that the FLAG is in the __second column__ or field of the file.
Hence we can do

    samtools view s040_reads_and_head.bam | cut -f 2

to get this second column or 

    samtools view s040_reads_and_head.bam | cut -f 2 | sort | uniq

to get the __unique__ values of the FLAG.

(Remember there are some tools to help you understand such flags: 
<http://broadinstitute.github.io/picard/explain-flags.html>)

We can then read just the _unmapped_ reads (flag 4) doing

    samtools view -f 4 s040_reads_and_head.bam

or the reads mapped to the _reverse strand_ (flag 16) doing

    samtools view -f 16 s040_reads_and_head.bam

- How would you use `wc` to confirm that the returned file is filtered? <!-- just count the number of lines with and without the -f option-->  
  You could also use the `-c` option of `samtools view` to count the number of lines...
  How does it work? <!-- samtools view -c -f 16 s040_reads_and_head.bam -->
- Does the command above include the header in its output? <!--no -->
- How would you do to include such header into the file? <!-- samtools view -h -f 16 s040_reads_and_head.bam -->
- How does the `-F` work? 



<!--
Nice NOTE on ZERO flags form <https://www.biostars.org/p/7374/>

When the __flag field is 0__,
it means none of the bitwise flags specified in the SAM spec (on page 4) are set.
That means that your reads with flag 0 are unpaired (because the first flag, 0x1, is not set),
successfully mapped to the reference (because 0x4 is not set)
and mapped to the forward strand (because 0x10 is not set).

Summarizing your data,
the reads with flag 4 are unmapped,
the reads with flag 0 are mapped to the forward strand
and the reads with flag 16 are mapped to the reverse strand.
-->


Filtering the alignments by Quality
--------------------------------------------------------------------------------

We can use `samtools view` to filter alignments according to their __quality__.
The `-q` option lets you set up a _minimum_ quality threshold for reads.

Remember the Quality of the alignment is in the __fifth column__ of the BAM file.
You can use `cut` to extract just such column of the file

    samtools view s040_reads.bam | cut -f 5
	samtools view s040_reads.bam | cut -f 5 | sort | uniq

Then we can keep just the good quality reads doing something like

    samtools view -q 30 s040_reads.bam


And of course several filtering options may be applied at a time:

    samtools view -f 16 -q 30 s040_reads.bam



Uncompressed binary files
---------------------------------------------------------------------------

What does the `-u` option does:

    samtools view -Sb -o s040_reads.bam s030_reads.sam
    samtools view -Su -o s040_reads_u.bam s030_reads.sam

(Read the manual and compare the output of the two commands above)



_Sort_ and _Index_
--------------------------------------------------------------------------------

Generally after alignment,
the rads in the SAM/BAM files have a random order.

You can see that in our example data getting just the fourth column of the file

    samtools view -F 4 s040_reads_and_head.bam | cut  -f 4

- What does the  `-F 4` option do? <!-- filters out the unmapped reads -->


The program `samtools sort` allow us sorting the alignments according to their chromosomal position

    samtools sort s040_reads_and_head.bam s050_sorted

Check that the new BAM file is ordered

    samtools view s050_sorted.bam | cut -f 4 

and that the header has been kept 

    samtools view -H s050_sorted.bam 

Remember the __unmapped__ reads had a __0__ position in their fourth column.

- What does the `samtools sort` option does to them? <!-- they go to the end of the file-->
  You can use `cut` to extract several fields or columns of a matrix  
  ```samtools view s050_sorted.bam | cut -f 2,4 | head -n 20```

\  

Sorting the reads is convenient for many purposes.
One of the main ones is that a sorted file can be __indexed__
so that access to it is sped up.

SAMtools have their __own indexing tool__ `samtools index`.

Once our BAM file is sorted, we can index it doing

    samtools index s050_sorted.bam

this will create the index file with the `-bai` extension.

- Can you index the unsorted file? <!-- NO -->
- Can you sort SAM files?  <!-- NO -->


Once we have a sorted and indexed BAM file, we can, for instance,
__access to some alignments by chromosomal position__

    samtools view s050_sorted.bam 21:44547700-44547750


Visualization
--------------------------------------------------------------------------------

Some other tools (not just SAMtools) rely up on the sorted and indexed BAM files to work.

It is the case of [IGV] which can be used to visualize read alignment to the genome.

Open IGV and load the `s050_sorted.bam`.

Find the reads of the file and see how they are displayed.

Remember in our example all reads are in __chromosome 21__.

Find the __base position__ of the read alignments and use the IGV _search_ box to find them in the genome.

