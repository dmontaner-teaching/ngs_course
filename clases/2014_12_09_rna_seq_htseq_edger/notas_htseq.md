read or a read pair ???



<http://www-huber.embl.de/users/anders/HTSeq/doc/count.html>


 count how many reads map to each feature.

RNA-Seq, the features are typically genes or exons

Special care must be taken to decide how to deal with reads that
overlap more than one feature
three modes...


If S contains precisely one feature, the read (or read pair) is counted for this feature.

If it __contains__ more than one feature, the read (or read pair) is counted as _ambiguous_ (and not counted for any features),

and if S is empty, the read (or read pair) is counted as __no_feature__.


Make sure to use a splicing-aware aligner such as TopHat. HTSeq-count makes full use of the information in the CIGAR field.


__no_feature: reads (or read pairs) which could not be assigned to any feature (set S as described above was empty).
__ambiguous: reads (or read pairs) which could have been assigned to more than one feature and hence were not counted for any of these (set S had mroe than one element).
__too_low_aQual: reads (or read pairs) which were skipped due to the -a option, see below
__not_aligned: reads (or read pairs) in the SAM file without alignment
__alignment_not_unique: reads (or read pairs) with more than one reported alignment. These reads are recognized from the NH optional SAM field tag. (If the aligner does not set this field, multiply aligned reads will be counted multiple times, unless they getv filtered out by due to the -a option.)


For __paired-end__ data, does htseq-count count reads or read pairs?
Read pairs. The script is designed to count “units of evidence” for gene expression. If both mates map to the same gene, this still only shows that one cDNA fragment originated from that gene. Hence, it should be counted only once.




htseq-count --format=bam --stranded=no --type=gene g031_case_sorted.bam f005_chr21_genome_annotation.gtf

htseq-count --format=bam --stranded=no --type=transcript g031_case_sorted.bam f005_chr21_genome_annotation.gtf >

htseq-count --format=bam --stranded=no --type=transcript --samout=salidasam --order=pos g031_case_sorted.bam f005_chr21_genome_annotation.gtf

htseq-count --format=bam --stranded=no --type=gene --samout=salidasam --order=pos g031_case_sorted.bam f005_chr21_genome_annotation.gtf


-m <mode>, --mode=<mode>
Mode to handle reads overlapping more than one feature. Possible values for <mode> are union, intersection-strict and intersection-nonempty (default: union)


htseq-count --format=bam --stranded=no --type=gene --samout=salidasam --order=pos --mode=intersection-strict g031_case_sorted.bam f005_chr21_genome_annotation.gtf

htseq-count --format=bam --stranded=no --type=gene --samout=salidasam --order=pos --mode=intersection-strict g031_case_sorted.bam f005_chr21_genome_annotation.gtf

htseq-count --format=bam --stranded=no --type=gene --samout=salidasam --mode=intersection-strict g031_case_sorted.bam f005_chr21_genome_annotation.gtf


Interesante gen con dos lecturas en g031
ENSG00000241945    2

Interesante con 5 lecturas... parece que solo cuenta las emparejadas ???
ENSG00000205930    5

samtools sort
-n	Sort by read names rather than by chromosomal coordinates


del Nature
In this protocol, we use the tool htseq-count of the Python package HTSeq, using the default union-counting mode;




