def multiqc_inputs(wildcards):
    inputs = [
        expand("qc/fastqc/{unit}.{pair}_fastqc.html",
               unit=get_units(), pair=["R1", "R2"]),
        expand("qc/cutadapt/{unit}.txt",
               unit=get_units()),
        expand("qc/samtools_stats/{sample}.txt", sample=get_samples()),
        expand("qc/picard_collect_hs_metrics/{sample}.txt",
               sample=get_samples()),
        expand("qc/picard_mark_duplicates/{sample}.metrics",
               sample=get_samples())
    ]

    if config["options"]["pdx"]:
        inputs += [expand("qc/disambiguate/{sample}.txt", sample=get_samples())]

    return [input_ for sub_inputs in inputs for input_ in sub_inputs]


rule multiqc:
    input:
        multiqc_inputs
    output:
        "qc/multiqc_report.html"
    params:
        " ".join(config["rules"]["multiqc"]["extra"])
    log:
        "logs/multiqc.log"
    conda:
        path.join(workflow.basedir, "envs/multiqc.yaml")
    wrapper:
        "0.17.0/bio/multiqc"


rule fastqc:
    input:
        "fastq/trimmed/{sample}.{lane}.{pair}.fastq.gz"
    output:
        html="qc/fastqc/{sample}.{lane}.{pair}_fastqc.html",
        zip="qc/fastqc/{sample}.{lane}.{pair}_fastqc.zip"
    params:
        " ".join(config["rules"]["fastqc"]["extra"])
    wrapper:
        "0.17.0/bio/fastqc"


rule samtools_stats:
    input:
        "bam/final/{sample}.bam"
    output:
        "qc/samtools_stats/{sample}.txt"
    wrapper:
        "0.17.0/bio/samtools/stats"


rule picard_collect_hs_metrics:
    input:
        bam="bam/final/{sample}.bam",
        reference=config["references"]["genome"],
        # Baits and targets should be given as interval lists. These can
        # can be generated from bed files using picard BedToIntervalList.
        bait_intervals=config["references"]["capture_intervals"],
        target_intervals=config["references"]["capture_intervals"]
    output:
        "qc/picard_collect_hs_metrics/{sample}.txt"
    params:
        extra=config["rules"]["picard_collect_hs_metrics"]["extra"]
    log:
        "logs/picard_collect_hs_metrics/{sample}.log"
    wrapper:
        "0.17.0/bio/picard/collecthsmetrics"
