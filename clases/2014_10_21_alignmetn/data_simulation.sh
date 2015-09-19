# Program: dwgsim (short read simulator)
# Version: 0.1.10
# Contact: Nils Homer <dnaa-help@lists.sourceforge.net>

# Usage:   dwgsim [options] <in.ref.fa> <out.prefix>

# Options:
#          -e FLOAT      per base/color/flow error rate of the first read [from 0.020 to 0.020 by 0.000]
#          -E FLOAT      per base/color/flow error rate of the second read [from 0.020 to 0.020 by 0.000]
#          -d INT        inner distance between the two ends [500] length of the insert
#          -s INT        standard deviation [50.000]
#          -N INT        number of read pairs (-1 to disable) [-1]
#          -C FLOAT      mean coverage across available positions (-1 to disable) [100.00]
#          -1 INT        length of the first read [70]
#          -2 INT        length of the second read [70]
#          -r FLOAT      rate of mutations [0.0010]
#          -R FLOAT      fraction of mutations that are indels [0.10]
#          -X FLOAT      probability an indel is extended [0.30]
#          -I INT        the minimum length indel [1]
#          -y FLOAT      probability of a random DNA read [0.05]
#          -n INT        maximum number of Ns allowed in a given read [0]
#          -c INT        generate reads for [0]:
#                            0: Illumina
#                            1: SOLiD
#                            2: Ion Torrent
#          -S INT        generate reads [0]:
#                            0: default (opposite strand for Illumina, same strand for SOLiD/Ion Torrent)
#                            1: same strand (mate pair)
#                            2: opposite strand (paired end)
#          -f STRING     the flow order for Ion Torrent data [(null)]
#          -B            use a per-base error rate for Ion Torrent data [False]
#          -H            haploid mode [False]
#          -z INT        random seed (-1 uses the current time) [-1]
#          -m FILE       the mutations txt file to re-create [not using]
#          -b FILE       the bed-like file set of candidate mutations [(null)]
#          -v FILE       the vcf file set of candidate mutations (use pl tag for strand) [(null)]
#          -x FILE       the bed of regions to cover [not using]
#          -P STRING     a read prefix to prepend to each read name [not using]
#          -q STRING     a fixed base quality to apply (single character) [not using]
#          -h            print this message

# Note: For SOLiD mate pair reads and BFAST, the first read is F3 and the second is R3. For SOLiD mate pair reads
# and BWA, the reads in the first file are R3 the reads annotated as the first read etc.

# Note: The longest supported insertion is 4294967295.


### NOTES FORM http://sourceforge.net/apps/mediawiki/dnaa/index.php?title=Whole_Genome_Simulation

# Error rates explained
# The "-e" and "-E" options accept a uniform error rate (i.e. "-e 0.01" for 1%), 
# or a uniformly increasing/decreasing error rate (i.e. "-e 0.01-0.1" for an error rate of 1% 
# at the start of the read increasing to 10% at the end of the read). 
# If you are generating Ion Torrent data ("-c 2"), then using the "-B" option will 
# try to adjust the per-flow error rates to produce the specified per-base error rates.

## REVISAR LO DE LA ORIENTACION DE LAS PAREJAS

################################################################################

#sed 's/>.*/>/' e000_transcriptome_chr20.fa > e010_transcriptome_chr20_noid.fa
#colordiff      e000_transcriptome_chr20.fa   e010_transcriptome_chr20_noid.fa

cd data

dwgsim -z 20141021 -N 100 -1 100 -2 100 -d 300 -y 0.1 -r 0.1 -R 0.1 f000_chr21_ref_genome_sequence.fa simulacion

cp simulacion.bwa.read1.fastq s010_reads.fastq

cp simulacion.bwa.read1.fastq p010_reads1.fastq
cp simulacion.bwa.read2.fastq p010_reads2.fastq

rm simulacion.bfast.fastq
rm simulacion.bwa.read*
