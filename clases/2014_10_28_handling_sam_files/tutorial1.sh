cd data
cd .. 
rm -r data_test
mkdir data_test
cp s030_reads.sam
samtools view -SH s030_reads.sam
samtools view -S s030_reads.sam
samtools view -S s030_reads.sam | head 
samtools view -Sh s030_reads.sam | head 
samtools view -Sb -o s040_reads.bam s030_reads.sam
ls -lh 
head s040_reads.bam
file *
samtools view s040_reads.bam
samtools view -Sbh -o s040_reads_and_head.bam s030_reads.sam
samtools -h view s040_reads_and_head.bam | head
samtools view -H s040_reads_and_head.bam
samtools view s040_reads_and_head.bam | cut -f 2
samtools view s040_reads_and_head.bam | cut -f 2 | sort | uniq
samtools view -f 4 s040_reads_and_head.bam
samtools view -f 16 s040_reads_and_head.bam
samtools view s040_reads.bam | cut -f 5
samtools view s040_reads.bam | cut -f 5 | sort | uniq
samtools view -q 30 s040_reads.bam
samtools view -f 16 -q 30 s040_reads.bam
samtools view -Sb -o s040_reads.bam s030_reads.sam
samtools view -Su -o s040_reads_u.bam s030_reads.sam
samtools view -F 4 s040_reads_and_head.bam | cut  -f 4
samtools sort s040_reads_and_head.bam s050_sorted
samtools view s050_sorted.bam | cut -f 4 
samtools view -H s050_sorted.bam 
samtools index s050_sorted.bam
samtools view s050_sorted.bam 21:44547700-44547750
