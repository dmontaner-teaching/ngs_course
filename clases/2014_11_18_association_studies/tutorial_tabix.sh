cd data
cd ..
rm -r data_test
mkdir data_test
cp data/005-dna_chr21_100_hq_pe_snps.vcf  data_test
cd data_test
cat 006-dna_chr21_100_he_pe_snps_filtered.vcf | vcf-sort > f010_sorted.vcf
bgzip f010_sorted.vcf
tabix f010_sorted.vcf.gz
tabix f010_sorted.vcf.gz 21:9417778-9429169
tabix f010_sorted.vcf.gz 21:48095473-48110969
tabix f010_sorted.vcf.gz 21:9417778-9429169 21:48095473-48110969
tabix ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase1/analysis_results/integrated_call_sets/ALL.chr20.integrated_phase1_v3.20101123.snps_indels_svs.genotypes.vcf.gz 20:60479-60571
