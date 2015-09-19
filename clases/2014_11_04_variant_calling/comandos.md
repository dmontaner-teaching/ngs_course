


[SAMstat]:http://sourceforge.net/projects/samstat/ "SAMstat home page"




    samtools view datos.bam | cut -f 3 | uniq


Some statistics


    samstat datos.bam 


Snp calling


pileup format (without -u or-g),


    samtools mpileup -f f000_chr21_ref_genome_sequence.fa s050_sorted.bam

    samtools mpileup -f f000_chr21_ref_genome_sequence.fa s050_sorted.bam > s060_pileup.txt

    samtools mpileup -g -f f000_chr21_ref_genome_sequence.fa s050_sorted.bam > s060_pileup_g.bcf

    samtools mpileup -u -f f000_chr21_ref_genome_sequence.fa s050_sorted.bam > s060_pileup_u.bcf






Convert between BCF and VCF, call variant candidates and estimate allele frequencies.
using `bcftools view`

    bcftools view s060_pileup_g.bcf > s070_pileup_g.vcf
    bcftools view s060_pileup_u.bcf > s070_pileup_u.vcf

colordiff s070_pileup_u.vcf s070_pileup_g.vcf 






<http://samtools.sourceforge.net/samtools.shtml>

each line represents a genomic position

| bcftools view bvcg

samtools mpileup [-EBug] [-C capQcoef] [-r reg] [-f in.fa] [-l list] [-M capMapQ] [-Q minBaseQ] [-q minMapQ] in.bam [in2.bam [...]]
Generate BCF or pileup for one or multiple BAM files. Alignment records are grouped by sample identifiers in @RG header lines. If sample identifiers are absent, each input file is regarded as one sample.

In the pileup format (without -u or -g),
each line represents a genomic position,
consisting of
1. chromosome name,
2. coordinate,
3. reference base,
4. read bases,
5. read qualities and
6. alignment mapping qualities.

Information on match, mismatch, indel, strand, mapping quality and start and end of a read are all encoded at the __read base column__.
At this column,
a __dot__ stands for a __match__ to the reference base on the __forward__ strand,
a __comma__ for a __match__ on the __reverse__ strand,
a ’>’ or ’<’ for a reference skip,
‘ACGTN’ for a __mismatch__ on the __forward__ strand and
‘acgtn’ for a __mismatch__ on the __reverse__ strand.
A pattern ‘\+[0-9]+[ACGTNacgtn]+’ indicates there is an __insertion__ between this reference position and the next reference position.
The length of the insertion is given by the integer in the pattern, followed by the inserted sequence.
Similarly, a pattern ‘-[0-9]+[ACGTNacgtn]+’ represents a __deletion__ from the reference.
The deleted bases will be presented as ‘*’ in the following lines. Also at the read base column, a symbol ‘^’ marks the start of a read. The ASCII of the character following ‘^’ minus 33 gives the mapping quality. A symbol ‘$’ marks the end of a read segment.


SOLO PARA LAS REGIONES DE COBERTURA

-------------------------------------------------------------------------------------------

Perdona David, se me olvidó pasarte el comando más sencillo de todos para hacer conteos con samtools:

samtools idxstats BAM > OUTPUT

el BAM debe estar ordenado con sort e indexado con index (generar el BAI)

Como resultado se obtiene un archivo tabulado con el gen, longitud, lecturas mapeadas y lecturas no mapeadas

Un saludo

-------------------------------------------------------------------------------------------

Hola David,

Te mando unos ejemplos de samttols para obtener el coverage, el coverage por región y hacer un recuento de lecturas mapeadas:

1. samtools -S -O -f REF BAM > OUTFILE (coverage por base). REF en formato fasta
2. coverageBed -split -abam BAM -b BED > OUTFILE (coverage por región, indica el número de lecturas mapeadas por región o gen). REF en  formato BED
3. samtools view -c BAM (número total de alineamientos)
4. samtools view -c -F 4 BAM (número de lecturas mapeadas)
5. samtools view -c -f 4 BAM (número de lecturas no mapeadas)
6. samtools view -c -f 1 -F12 BAM (número de lecturas mapeadas en datos paired-end)

Un saludo



-------------------------------------------------------------------------------------------

Hola David,

Te mando los comandos de samstat y el variant calling con samtools:

1. El informe con samstat se genera de una manera bastante sencilla:

samstat <BAM>

En el mismo directorio se generará un archivo HTML con el mismo nombre del BAM


2. Para realizar el variant calling con samtools:
    2.1. Hay que generar el BCF con samtools
    2.2. Covertir el BCF en VCF

outdir = variant_calling.bcf
outdir2 = variant_calling.vcf
REF = Genoma e referencia indexado (bowtie, bwa...)

samtools mpileup -uD -f REF BAM | bcftools view bvcg -> outdir

-u genera un BCF no comprimido
-D genera un output por muestra
-f genoma de referencia

bcftools view outdir | /usr/share/samtools/./vcfutils.pl varFilter -Q20 -d30 -D1000 > outdir2

-Q quality score (mapping)
-d profundidad minima
-D profundidad máxima
