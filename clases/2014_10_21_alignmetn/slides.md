---
title: Alignment of NGS reads
subtitle: 'Estudios in silico en Biomedicina \newline _(Máster en Bioinformática, Universidad de Valencia)_'
author: '[David Montaner](http://www.dmontaner.com)'
date: 2014-10-21
footer-left: 'Estudios in silico en Biomedicina'
footer-right: Alignment
...


Aligners
================================================================================

- BWA : DNA
- Bowtie / Tophat : RNA
- ...


Alignment steps
---------------

1. Index the reference
2. Align (may be spitted up in several steps)

Other Considerations
--------------------

- paired ends / single ends
- Reference genome is assumed


SAM Format
================================================================================

[sam]:http://samtools.github.io/hts-specs/SAMv1.pdf "http://samtools.github.io/hts-specs/SAMv1.pdf"

[SAM] : Sequence Alignment/Map format.

A TAB-delimited text format storing the alignment information.

A _header section_ is optional.


SAM Mandatory fields 
================================================================================

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









<!-- 
Intro
================================================================================


- paired ends single ends

- coverage 

- Reference genome Links / Download

Alignment/Map


 Mapping reads onto a reference
genome, a simple concept but there are
some challenges:

 Natural variability: SNPs, de novo
mutations, INDELS, copy number,
translocations, ...

 Repetitive regions

 Sequencing errors

 RNA-seq: gapped alignment

 BS-seq: C T conversion strategy

 High computing resources needed:
multicore CPUs and a lot of RAM

 We must deal with genomic variation in
an efficient way

-->
