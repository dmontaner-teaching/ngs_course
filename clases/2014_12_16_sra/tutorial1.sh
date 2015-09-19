fastq-dump SRR1103937.sra
fastq-dump SRR926292
sam-dump SRR1103937.sra > mysamfile.sam

samtools view -Sb mysamfile.sam -o mysamfile.bam
sam-dump SRR1103937.sra | samtools view -Sb mysamfile.sam -o mysamfile.bam 
sam-dump SRR1103937 | head 
sam-dump --header SRR1103937.sra > mysamfile_with_header.sam
sam-dump --header-comment 'THIS IS MY CUSTOM TEXT' SRR1103937.sra > mysamfile_with_custom_header.sam
sam-dump --version
