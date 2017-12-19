rule cutadapt:
    input:
        ["fastq/raw/{sample}.{lane}.R1.fastq.gz",
         "fastq/raw/{sample}.{lane}.R2.fastq.gz"]
    output:
        fastq1=temp("fastq/trimmed/{sample}.{lane}.R1.fastq.gz"),
        fastq2=temp("fastq/trimmed/{sample}.{lane}.R2.fastq.gz"),
        qc="qc/cutadapt/{sample}.{lane}.txt"
    params:
        " ".join(config["rules"]["cutadapt"]["extra"])
    log:
        "logs/cutadapt/{sample}.{lane}.log"
    wrapper:
        "0.17.0/bio/cutadapt/pe"
