# 🧬 Long-Read Genomic Variant Calling Pipeline

Author: EhsanOmics  
Description: A reproducible Snakemake pipeline for long-read variant calling, annotation, and filtering using Clair3, Sniffles, and Ensembl VEP.

📌 Overview:
This pipeline processes raw FASTQ files from Oxford Nanopore or PacBio to produce high-confidence, annotated variants. It includes:
- Alignment using Minimap2
- SNP calling via Clair3
- Structural variant detection using Sniffles
- Annotation using Ensembl VEP
- Filtering with bcftools

Tested on Linux and AWS EC2. Modular, scalable, and reproducible.

⚙️ Configuration:
Edit config/config.yaml to define:
- Sample names
- Reference genome path
- VEP cache location
- Thread count

Example:
samples:
  - sample1
reference: "reference/genome.fa"
vep_cache: "vep_cache/"
threads: 8

🐍 Workflow Steps:
- align_reads: Minimap2 alignment
- call_snps: Clair3 SNP calling
- call_svs: Sniffles SV detection
- merge_variants: Combine SNPs and SVs
- annotation: VEP annotation
- filter_variants: bcftools filtering

🧪 Environment Setup:
conda env create -f envs/clair3.yaml
conda env create -f envs/sniffles.yaml
conda env create -f envs/vep.yaml

clair3.yaml:
name: clair3
channels:
  - bioconda
  - conda-forge
dependencies:
  - clair3
  - samtools

sniffles.yaml:
name: sniffles
channels:
  - bioconda
dependencies:
  - sniffles

vep.yaml:
name: vep
channels:
  - bioconda
dependencies:
  - ensembl-vep
  - bcftools
  - tabix

🚀 Run the Pipeline:
snakemake --cores 8

📦 Output:
filtered/final_annotated.vcf.gz

🧬 About EhsanOmics:
This project is part of the EhsanOmics initiative to build reproducible, open-source bioinformatics tools for genomic research.  
Feel free to fork, contribute, or reach out for collaboration.

linkedin.com/in/ehsanjarianie
