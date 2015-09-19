

A algunos alumnos les falla el indexado y tienen que hacerlo de nuevo: 


El error que me daba el MarkDuplicates era que el archivo bam : no
coordinate sorted.

Con esta linea se ordena :

picard-tools SortSam INPUT=000-dna_chr21_100_hq_pe.bam
OUTPUT=21pic_pe_sorted.bam SORT_ORDER=coordinate

Luego se indexa con samtools index y se sigue normalmente.


Hay que revisar la parte de SE... 


