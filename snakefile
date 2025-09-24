configfile: "config.yaml"

rule all:
    input:
        "filtered/final_annotated.vcf.gz"

rule align_reads:
    input:
        fastq="raw_data/{sample}.fastq.gz",
        ref="reference/genome.fa"
    output:
        bam="alignment/{sample}.bam",
        bai="alignment/{sample}.bam.bai"
    threads: 8
    shell:
        """
        minimap2 -t {threads} -a {input.ref} {input.fastq} | \
        samtools sort -@ {threads} -o {output.bam}
        samtools index {output.bam}
        """

rule call_snps:
    input:
        bam="alignment/{sample}.bam",
        ref="reference/genome.fa"
    output:
        vcf="snp_calls/{sample}.vcf.gz"
    threads: 8
    shell:
        """
        clair3.sh \
        --bam_fn {input.bam} \
        --ref_fn {input.ref} \
        --output {wildcards.sample}_clair3 \
        --threads {threads}
        cp {wildcards.sample}_clair3/merge_output.vcf.gz {output.vcf}
        """

rule call_svs:
    input:
        bam="alignment/{sample}.bam",
        ref="reference/genome.fa"
    output:
        vcf="sv_calls/{sample}_sv.vcf"
    threads: 4
    shell:
        """
        sniffles --input {input.bam} --reference {input.ref} --vcf {output.vcf} --threads {threads}
        """

rule merge_variants:
    input:
        snp_vcf="snp_calls/{sample}.vcf.gz",
        sv_vcf="sv_calls/{sample}_sv.vcf"
    output:
        merged="variants/{sample}_merged.vcf"
    shell:
        """
        bcftools concat -a {input.snp_vcf} {input.sv_vcf} -o {output.merged} -O v
        """

rule annotate_variants:
    input:
        vcf="variants/{sample}_merged.vcf",
        cache="vep_cache/"
    output:
        annotated="annotation/{sample}_annotated.vcf"
    shell:
        """
        vep -i {input.vcf} --cache --dir_cache {input.cache} \
        --vcf --force_overwrite -o {output.annotated}
        """

rule filter_variants:
    input:
        vcf="annotation/{sample}_annotated.vcf"
    output:
        filtered="filtered/final_annotated.vcf.gz"
    shell:
        """
        bcftools filter -i 'QUAL>20 && DP>10' {input.vcf} | \
        bgzip -c > {output.filtered}
        tabix -p vcf {output.filtered}
        """
