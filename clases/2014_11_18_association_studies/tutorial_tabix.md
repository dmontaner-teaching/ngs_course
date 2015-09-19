% NGS data analysis tutorial: <br> TABIX
% [Estudios in silico en Biomedicina](http://www.uv.es/bioinfor/) <br> _Máster en Bioinformática, Universidad de Valencia_
% [David Montaner](http://www.dmontaner.com) <br> _2014-11-18_

<!-- COMMON LINKS HERE -->

[vcftools]: http://vcftools.sourceforge.net/ "VCFtools: A package for working with VCF files: merging, comparing, annotating ..."
[tabix]:http://samtools.sourceforge.net/tabix.shtml "tabix: compress and index TAB-delimited files. Useful for handling GFF, GTF, BED and VCF files"

[vcftools-perl-man]:http://vcftools.sourceforge.net/perl_module.html "VCFtools Perl Module man"
[vcftools-man]:http://vcftools.sourceforge.net/man_latest.html "VCFtools man"
[tabix-man]:http://samtools.sourceforge.net/tabix.shtml "tabix man"

[vcf-format-1000ge]:http://www.1000genomes.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-41
[vcf-format-wikipedia]:http://en.wikipedia.org/wiki/Variant_Call_Format

[1000 genomes]:http://www.1000genomes.org/ "1000 Genomes Home Page"


Preliminaries
================================================================================


Software used in this practical:
--------------------------------

- [VCFtools] : A package for working with VCF files: merging, comparing, annotating ...
- [tabix] : compress and index TAB-delimited files. Useful for handling GFF, GTF, BED and VCF files.


File formats explored:
----------------------

- VCF Variant Call Format: see [1000 Genomes][vcf-format-1000ge] and [Wikipedia][vcf-format-wikipedia] specifications.


Overview
================================================================================

1. Use [VCFtools] (perl module) to sort VCF file. 
1. Use [tabix] to index the VCF file and then to query some information from it.
1. Use [tabix] to query __remote__ data.



Exercise
================================================================================

We will fork with the VCF file `006-dna_chr21_100_he_pe_snps_filtered.vcf`
created in previous practicals.

Copy it in your working directory and go to it.

    cd data

<!-- data_test directory to run my examples
    cd ..
    rm -r data_test
    mkdir data_test
    cp data/005-dna_chr21_100_hq_pe_snps.vcf  data_test
    cd data_test
-->

<!-- interesante para mas adelante
vcftools --vcf 006-dna_chr21_100_he_pe_snps_filtered.vcf --out 007-fileterd --chr 21 --from-bp 9417778 --to-bp 9439226 --recode
-->


In order to use [tabix] the VCF file needs to be _sorted_ according to genomic position.

We will first use the [perl module][vcftools-perl-man] in [VCFtools][vcftools-man] to __sort__ our data.

    cat 006-dna_chr21_100_he_pe_snps_filtered.vcf | vcf-sort > f010_sorted.vcf

- Why do we need to use the `cat` command?
- How would you check that the `vcf-sort` command is working?


In the [tabix] pipeline we need first to __compress__ the _sorted_ VCF file.

    bgzip f010_sorted.vcf

- What happened to the file


Now we can index the _compressed_ file using `tabix`.

    tabix f010_sorted.vcf.gz

- Where is the index created?


Now tabix can be used to efficiently access some regions of VCF file.

    tabix f010_sorted.vcf.gz 21:9417778-9429169
	tabix f010_sorted.vcf.gz 21:48095473-48110969
    tabix f010_sorted.vcf.gz 21:9417778-9429169 21:48095473-48110969

- Where are the header lines of the VCF file?
- Can you print them using tabix? (see help)

The command `bgzip -d` may help you recovering the unzipped version of the file.


Remote access
-----------------

Tabix also allows for accessing remote files... try:

    tabix ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase1/analysis_results/integrated_call_sets/ALL.chr20.integrated_phase1_v3.20101123.snps_indels_svs.genotypes.vcf.gz 20:60479-60571


<!--
cp sorted.vcf scorted_bckp.vcf
bgzip -c corted_bckp.vcf > sorted2.vcf.gz
-->

