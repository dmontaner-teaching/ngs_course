java -jar ../picard/CreateSequenceDictionary.jar
picard-tools CreateSequenceDictionary
GATK
java -jar ../gatk/GenomeAnalysisTK.jar
cd data
cd ..
rm -r data_test
mkdir data_test
cp data/f000_chr21_ref_genome_sequence.fa data_test
cp data/000-dna_chr21_100_hq_se.bam       data_test
cp data/000-dna_chr21_100_hq_pe.bam       data_test 
cp data/000-dbSNP_chr21.vcf               data_test
cd data_test
samtools faidx f000_chr21_ref_genome_sequence.fa
##java -jar ../picard/CreateSequenceDictionary.jar REFERENCE=f000_chr21_ref_genome_sequence.fa OUTPUT=f000_chr21_ref_genome_sequence.dict
picard-tools CreateSequenceDictionary REFERENCE=f000_chr21_ref_genome_sequence.fa OUTPUT=f000_chr21_ref_genome_sequence.dict
AddOrReplaceReadGroups.jar I=f000-dna_100_high_pe.bam O=f010-dna_100_high_pe_fixRG.bam RGID=group1 RGLB=lib1 RGPL=illumina RGSM=sample1 RGPU=unit1
samtools sort 000-dna_chr21_100_hq_pe.bam 001-dna_chr21_100_hq_pe_sorted
samtools index 001-dna_chr21_100_hq_pe_sorted.bam
##java -jar ../picard/MarkDuplicates.jar INPUT=001-dna_chr21_100_hq_pe_sorted.bam OUTPUT=002-dna_chr21_100_hq_pe_sorted_noDup.bam METRICS_FILE=002-metrics.txt
picard-tools MarkDuplicates INPUT=001-dna_chr21_100_hq_pe_sorted.bam OUTPUT=002-dna_chr21_100_hq_pe_sorted_noDup.bam METRICS_FILE=002-metrics.txt
##java -jar ../picard/BuildBamIndex.jar INPUT=002-dna_chr21_100_hq_pe_sorted_noDup.bam
picard-tools BuildBamIndex INPUT=002-dna_chr21_100_hq_pe_sorted_noDup.bam
##java -jar ../gatk/GenomeAnalysisTK.jar -T RealignerTargetCreator -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_pe_sorted_noDup.bam -o 003-indelRealigner.intervals
GATK -T RealignerTargetCreator -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_pe_sorted_noDup.bam -o 003-indelRealigner.intervals
##java -jar ../gatk/GenomeAnalysisTK.jar -T IndelRealigner -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_pe_sorted_noDup.bam -targetIntervals 003-indelRealigner.intervals -o 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam
GATK -T IndelRealigner -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_pe_sorted_noDup.bam -targetIntervals 003-indelRealigner.intervals -o 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam
##java -jar ../gatk/GenomeAnalysisTK.jar -T BaseRecalibrator -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam -knownSites ../000-dbSNP_chr21.vcf -o 004-recalibration_data.table
GATK -T BaseRecalibrator -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam -knownSites 000-dbSNP_chr21.vcf -o 004-recalibration_data.table
##java -jar ../gatk/GenomeAnalysisTK.jar -T PrintReads -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam -BQSR 004-recalibration_data.table -o 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam
GATK -T PrintReads -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_pe_sorted_noDup_realigned.bam -BQSR 004-recalibration_data.table -o 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam
##java -jar ../gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam -glm SNP -o 005-dna_chr21_100_he_pe_snps.vcf
GATK -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam -glm SNP -o 005-dna_chr21_100_he_pe_snps.vcf
##java -jar ../gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam -glm INDEL -o 005-dna_chr21_100_hq_pe_indel.vcf
GATK -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_pe_sorted_noDup_realigned_recalibrated.bam -glm INDEL -o 005-dna_chr21_100_hq_pe_indel.vcf
##java -jar ../gatk/GenomeAnalysisTK.jar -T VariantFiltration -R f000_chr21_ref_genome_sequence.fa -V 005-dna_chr21_100_he_pe_snps.vcf --filterExpression "QD<12.0" --filterName "LowConf" -o 006-dna_chr21_100_he_pe_snps_filtered.vcf
GATK -T VariantFiltration -R f000_chr21_ref_genome_sequence.fa -V 005-dna_chr21_100_he_pe_snps.vcf --filterExpression "QD<12.0" --filterName "LowConf" -o 006-dna_chr21_100_he_pe_snps_filtered.vcf
grep LowConf 006-dna_chr21_100_he_pe_snps_filtered.vcf | wc -l
--filterExpression "QD < 12.0"
cd /home/participant/cambridge_mda14/calling/example2
samtools sort 000-dna_chr21_100_hq_se.bam 001-dna_chr21_100_hq_se_sorted
samtools index 001-dna_chr21_100_hq_se_sorted.bam
java -jar ../picard/MarkDuplicates.jar INPUT=001-dna_chr21_100_hq_se_sorted.bam OUTPUT=002-dna_chr21_100_hq_se_sorted_noDup.bam METRICS_FILE=002-metrics.txt
java -jar ../picard/BuildBamIndex.jar INPUT=002-dna_chr21_100_hq_se_sorted_noDup.bam
java -jar ../gatk/GenomeAnalysisTK.jar -T RealignerTargetCreator -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_se_sorted_noDup.bam -o 003-indelRealigner.intervals
java -jar ../gatk/GenomeAnalysisTK.jar -T IndelRealigner -R f000_chr21_ref_genome_sequence.fa -I 002-dna_chr21_100_hq_se_sorted_noDup.bam -targetIntervals 003-indelRealigner.intervals -o 003-dna_chr21_100_hq_se_sorted_noDup_realigned.bam
java -jar ../gatk/GenomeAnalysisTK.jar -T BaseRecalibrator -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_se_sorted_noDup_realigned.bam -knownSites ../000-dbSNP_chr21.vcf -o 004-recalibration_data.table
java -jar ../gatk/GenomeAnalysisTK.jar -T PrintReads -R f000_chr21_ref_genome_sequence.fa -I 003-dna_chr21_100_hq_se_sorted_noDup_realigned.bam -BQSR 004-recalibration_data.table -o 004-dna_chr21_100_hq_se_sorted_noDup_realigned_recalibrated.bam
java -jar ../gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_se_sorted_noDup_realigned_recalibrated.bam -glm SNP -o 005-dna_chr21_100_hq_se_snps.vcf
java -jar ../gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -R f000_chr21_ref_genome_sequence.fa -I 004-dna_chr21_100_hq_se_sorted_noDup_realigned_recalibrated.bam -glm INDEL -o 005-dna_chr21_100_hq_se_indel.vcf
