samstat s050_sorted.bam
rm -r data_test
mkdir data_test
cp data/s050_sorted.bam data_test
cp data/f000_chr21_ref_genome_sequence.fa data_test
cd data
samtools view -H s050_sorted.bam
samtools view s050_sorted.bam | head
samtools view s050_sorted.bam | cut -f 4 | head
samtools mpileup -f f000_chr21_ref_genome_sequence.fa s050_sorted.bam
samtools mpileup -f f000_chr21_ref_genome_sequence.fa s050_sorted.bam > s060_pileup.txt
head s060_pileup.txt 
samtools mpileup -g -f f000_chr21_ref_genome_sequence.fa s050_sorted.bam > s060_pileup.bcf
bcftools view s060_pileup.bcf > s070_variants.vcf
samtools mpileup -u -f f000_chr21_ref_genome_sequence.fa s050_sorted.bam | bcftools view -> my.vcf
bcftools view s060_pileup_g.bcf > s070_pileup_g.vcf
bcftools view s060_pileup_u.bcf > s070_pileup_u.vcf
colordiff s070_pileup_u.vcf s070_pileup_g.vcf 
2.1. Hay que generar el BCF con samtools
2.2. Covertir el BCF en VCF
