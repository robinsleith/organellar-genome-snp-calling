#!/bin/bash

#reference genome
index=CP_assembly_consensus.fa

#directory of trimmed reads
cd /N/dc2/scratch/rsleith/CSHL/samples/trim/
for i in *_for_paired_out.fastq.gz
do
export name1=$i
export name2=${i/R1_001.fastq.gz_for_/R2_001.fastq.gz_rev_}

#map reads to reference indicated above with index
bwa mem "/N/u/rsleith/Carbonate/refs/"$index -M -B 4 -t 20 \
"/N/dc2/scratch/rsleith/CSHL/samples/trim/"$name1 "/N/dc2/scratch/rsleith/CSHL/samples/trim/"$name2 \
| samtools view -h -b -S -f 0x0002 | samtools sort >"/N/dc2/scratch/rsleith/bwa/snp_pipeline_trim/sorted/Sort-"$name1".bam"
echo $i >>/N/dc2/scratch/rsleith/bwa/snp_pipeline_trim/sorted/flagstat.txt
samtools flagstat "/N/dc2/scratch/rsleith/bwa/snp_pipeline_trim/sorted/Sort-"$name1".bam" >>/N/dc2/scratch/rsleith/bwa/snp_pipeline_trim/sorted/flagstat.txt
done

#create mpileup file for SNP calling
samtools mpileup -B -f "/N/dc2/scratch/rsleith/bwa/index/"$index -D /N/dc2/scratch/rsleith/bwa/snp_pipeline_trim/sorted/*.bam > /N/dc2/scratch/rsleith/bwa/snp_pipeline_trim/sorted/Calling.mpileup

#call SNPs with VarScan
java -jar /N/u/rsleith/Carbonate/varscan-master/VarScan.v2.4.3.jar mpileup2cns /N/dc2/scratch/rsleith/bwa/snp_pipeline_trim/sorted/Calling.mpileup \
--min-var-freq 0.90 --min-avg-qual 30 --min-freq-for-hom 0.5 --output-vcf 1 --min-coverage 3 --strand-filter 0 > /N/dc2/scratch/rsleith/bwa/snp_pipeline_trim/sorted/Calling.vcf