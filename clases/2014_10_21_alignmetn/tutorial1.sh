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
cd data
cd .. 
rm -r data_test
mkdir data_test
cp data/*fa data_test
cp data/*fastq data_test
cd data_test
grep "^>" f000_chr21_ref_genome_sequence.fa
grep -v "^>" f000_chr21_ref_genome_sequence.fa | wc -l -m
wc -l *fastq
grep "^@" p010_reads1.fastq
grep "^@" p010_reads2.fastq 
bwa index -a bwtsw f000_chr21_ref_genome_sequence.fa 
bwa aln -f s020_reads.sai f000_chr21_ref_genome_sequence.fa s010_reads.fastq 
bwa samse -f s030_reads.sam -r "@RG\tID:sample1" f000_chr21_ref_genome_sequence.fa s020_reads.sai s010_reads.fastq 
head s030_reads.sam
bwa aln -f p020_reads1.sai f000_chr21_ref_genome_sequence.fa p010_reads1.fastq
bwa aln -f p020_reads2.sai f000_chr21_ref_genome_sequence.fa p010_reads2.fastq 
bwa sampe -f p030_reads.sam -r "@RG\tID:sample1" f000_chr21_ref_genome_sequence.fa p020_reads1.sai p020_reads2.sai p010_reads1.fastq p010_reads2.fastq 
