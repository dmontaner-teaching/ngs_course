

SRA(NCBI) stores all the sequencing run as single "sra" or "lite.sra" file. You may want separate files if you want to use the data from paired-end sequencing. When I run SRA toolkit's "fastq-dump" utility on paired-end sequencing SRA files, sometimes I get only one files where all the mate-pairs are stored in one file rather than two or three files.
The solution for the problem is to always run fastq-dump with "--split-3" option. If the experiment is single-end sequencing, only one fastq file will be generated. If it is paired-end sequencing, there may be two or three fastq files.
Two files (with suffix "_1" and "_2") are matched mate-pair read file where as the third one (without any suffix) contains all the reads that do not have any mate-paires (or SRA couldn't resolve mate-paires for them).




http://vinaykmittal.blogspot.com.es/2012/02/how-to-extract-paired-end-reads-from.html
