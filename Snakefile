# WGD analysis pipeline
# ---------------------
# add samples in samples.tsv, along with their associated paths
# all parameters in in config.yaml

import pandas as pd
from pathlib import Path

configfile: "config.yaml"
# ---------------------
# load samples.tsv
df_samples = pd.read_csv(config["samples"], sep = "\t", index_col = "sample")
samples = list(df_samples.index)
path_outdir = config["outdir"]

def s(sample, col): # to make it easier downstream
    return df_samples.loc[sample, col]

focal = config["viz"]["focal_sample"] # exidia

# ---------------------
# rule all
rule all:
    input:
        expand( # busco
            "{outdir}/Busco/{sample}/short_summary.specific.{sample}.txt", # busco output
        zip, # pairwise, not 
        outdir = [path_outdir] * len(samples),
        sample = samples,
        lineage = [s(sp, "busco_lineage") for sp in samples],
        ), # assembly stat
        expand("{outdir}/Assembly/{sample}/{sample}_stats.txt",
        outdir = path_outdir,
        sample = samples,
        ), #wgd dmd intra
        expand("{outdir}/DMD/{sample}/{sample}_clean.fasta.tsv",
        outdir = path_outdir,
        sample = samples,
        ), # wgd ksd intra
        expand("{outdir}/KSD/{sample}/{sample}_clean.fasta.tsv.ks.tsv",
        outdir = path_outdir,
        sample = samples,
        ), # wgd syn intra
        expand("{outdir}/SYN/{sample}/iadhore-out/anchorpoints.txt",
        outdir = path_outdir,
        sample = samples,
        ), # interspecific syn
        f"{path_outdir}/InterSpecific/DMD/Orthogroups.sp.tsv",
        f"{path_outdir}/InterSpecific/KSD/Orthogroups.sp.tsv.ks.tsv"
        # f"{path_outdir}/InterSpecific/SYN/iadhore-out/anchorpoints.txt"

# ---------------------
# BUSCO rule

def busco_lineage(wildcard):
    return s(wildcard.sample, "busco_lineage")

def busco_aa(wildcard):
    return s(wildcard.sample, "aa_fasta")

rule busco:
    input:
        fasta = lambda wc: s(wc.sample, "aa_fasta"),
    output:
        summary = "{outdir}/Busco/{sample}/short_summary.specific.{sample}.txt",
    params:
        lineage = lambda wc: s(wc.sample, "busco_lineage"),
        outdir = lambda wc: f"{wc.outdir}/Busco/{wc.sample}",
        mode = config["busco"]["mode"],
    threads: config["threads"]["busco"]
    conda: "envs/busco.yaml"
    log: "{outdir}/Busco/{sample}/{sample}_busco.log"
    shell:
        """            
        busco \
        -i {input.fasta} \
        -l {params.lineage} \
        -o {params.outdir} \
        -m {params.mode} \
        -c {threads} \
        -f > {log} 2>&1
        """

# ---------------------
# rule assembly stats

rule assembly_stats:
    input:
        genome = lambda wc: s(wc.sample, "genome_fasta"),
    output:
        stats = "{outdir}/Assembly/{sample}/{sample}_stats.txt"
    threads: config["threads"]["stats"]
    conda: "envs/bbtools.yaml"
    log: "{outdir}/Assembly_Stats/{sample}/{sample}_stats.log"
    shell:
        """
        stats.sh \
        in={input.genome} \
        out={output.stats} \
        2> {log}
        """

# ---------------------
# rule clean up JGI-headers

rule clean_headers:
    input:
        CDS = lambda wc: s(wc.sample, "cds_fasta"),
    output:
        clean_CDS = "Data/Clean_Data/{sample}/{sample}_clean.fasta",
    params:
        pattern = lambda wc: config["clean_headers"][wc.sample], # sed
    shell: # only sed jgi headers, or whatever you want essentially, if its added to the config file
        """ 
        if [ -z "{params.pattern}" ]; then
        cp {input.CDS} {output.clean_CDS}
        else
        sed '{params.pattern}' {input.CDS} > {output.clean_CDS}
        fi
        """

# ---------------------
# rule make GFF files for Exidia and Calco, whereas Auri has a proper gff3
rule gff:
    input:
        raw_gff = lambda wc: s(wc.sample, "gff"),
    output:
        gff = "Scripts/{sample}.gff",
    conda: "envs/pyutils.yaml"
    shell:
        """
        python Scripts/gff_make_gff.py \
        {input.raw_gff} \
        {output.gff}
        """

# ---------------------
# rule wgd dmd intra

rule dmd_intra:
    input:
        fasta = "Data/Clean_Data/{sample}/{sample}_clean.fasta",
    output:
        dmd = "{outdir}/DMD/{sample}/{sample}_clean.fasta.tsv",
    params:
        outdir = lambda wc: f"{wc.outdir}/DMD/{wc.sample}", # wgd wants this
    threads: config["threads"]["dmd"]
    conda: "envs/wgd.yaml"
    log: "{outdir}/DMD/{sample}/{sample}_dmd.log"
    shell:
        """
        wgd dmd \
        {input.fasta} \
        -o {params.outdir}
        -n {threads} \
        > {log} 2>&1
        """

# ---------------------
# rule wgd ksd intra

rule ksd_intra:
    input:
        fasta = "Data/Clean_Data/{sample}/{sample}_clean.fasta",
        tsv = "{outdir}/DMD/{sample}/{sample}_clean.fasta.tsv",
    output:
        ksd = "{outdir}/KSD/{sample}/{sample}_clean.fasta.tsv.ks.tsv",
    params:
        outdir = lambda wc: f"{wc.outdir}/KSD/{wc.sample}",
    threads: config["threads"]["ksd"]
    conda: "envs/wgd.yaml"
    log: "{outdir}/KSD/{sample}/{sample}_ksd.log"
    shell:
        """
        wgd ksd \
        {input.tsv} \
        {input.fasta} \
        -o {params.outdir}
        -n {threads} \
        > {log} 2>&1
        """

# ---------------------
# rule wgd syn intra

# hard-printed function to make sure only exi and calco is given to the make_gff.py script
def gff_input(wildcard):
    if wildcard.sample == "Auri":
        return s(wildcard.sample, "gff") # keep Auris gff3
    return f"Scripts/{wildcard.sample}.gff"

# flag for gff that has different attribute and/or feature, e.g. -a Name -f gene
def gff_flags(wildcard):
    attribute = s(wildcard.sample, "gff_id_attr")
    feature = s(wildcard.sample, "gff_feature_type")
    flags = []
    if attribute != "ID": # standard in wgd
        flags += [f"-a {attribute}"]
    if feature != "gene": # standard in wgd
        flags += [f"-f {feature}"]
    return " ".join(flags)
    
# rule
rule syn_intra:
    input:
        tsv = "{outdir}/DMD/{sample}/{sample}_clean.fasta.tsv",
        gff = gff_input,
        ksd = "{outdir}/KSD/{sample}/{sample}_clean.fasta.tsv.ks.tsv",
    output:
        syn = "{outdir}/SYN/{sample}/iadhore-out/anchorpoints.txt",
    params:
        outdir = lambda wc: f"{wc.outdir}/SYN/{wc.sample}",
        mingenenum = config["syn"]["mingenenum"],
        dotsize = config["syn"]["dotsize"],
        apalpha = config["syn"]["apalpha"],
        hoalpha = config["syn"]["hoalpha"],
        flags = gff_flags,
    threads: config["threads"]["syn"]
    conda: "envs/wgd.yaml"
    log: "{outdir}/SYN/{sample}/{sample}_syn.log"
    shell: 
        """
        wgd syn \
        {input.tsv} \
        {input.gff} \
        -ks {input.ksd} \
        {params.flags} \
        -o {params.outdir} \
        --mingenenum {params.mingenenum} \
        --dotsize {params.dotsize} \
        --apalpha {params.apalpha} \
        --hoalpha {params.hoalpha} \
        -n {threads} \
        > {log} 2>&1
        """

# ---------------------
# rule interspecific prep

# rule that adds a prefix to each gene to avoid gene collisions in i-adhore, first to the fasta files
rule prefix_fasta:
    input:
        fasta = "Data/Clean_Data/{sample}/{sample}_clean.fasta",
    output:
        prefixed_fasta = "Data/Clean_Data/{sample}/Inter/{sample}_inter.fasta",
    params:
        prefix = lambda wc: config["inter_prefix"][wc.sample],
    shell:
        """
        if [ -z "{params.prefix}" ]; then
        cp {input.fasta} {output.fasta}
        else
        sed 's/^>/>{params.prefix}/' {input.fasta} > {output.fasta}
        fi
        """

# rule for the gffs
rule prefix_gff:
    input:
        gff = gff_input,
    output:
        gff = "Scripts/{sample}_prefixed.gff",
    params:
        prefix = lambda wc: config["inter_prefix"][wc.sample],
        attribute = lambda wc: s(wc.sample, "gff_id_attr"),
        feature = lambda wc: s(wc.sample, "gff_feature_type"),
    shell:
        """
        if [ -z "{params.prefix}" ]; then
        cp {input.gff} {output.gff}
        else
        awk '$3=="{params.feature}" {gsub(/{params.attribute}=/, "{params.attribute}={params.prefix}")} {print}' \
        {input.gff} > {output.gff}
        fi
        """

# ---------------------
# rule interspecific dmd

rule inter_dmd:
    input:
        fastas = expand(
            "Data/Clean_Data/{sample}/Inter/{sample}_inter.fasta",
            sample = samples
        ),
    output:
        tsv = f"{path_outdir}/InterSpecific/DMD/Orthogroups.sp.tsv"
    params:
        outdir = "f{path_outdir}/InterSpecific/DMD",
    threads: config["threads"]["inter"]
    conda: "envs/wgd.yaml"
    log: "f{path_outdir}/InterSpecific/DMD/inter_dmd.log"
    shell:
        """
        wgd dmd \
        -oo \
        -oi {input.fastas} \
        -o {params.outdir} \
        -n {threads} \
        > {log} 2>&1
        """

# ---------------------
# rule interspecific ksd

rule inter_ksd:
    input:
        tsv = f"{path_outdir}/InterSpecific/DMD/Orthogroups.sp.tsv",
        fastas = expand(
            "Data/Clean_Data/{sample}/Inter/{sample}_inter.fasta",
            sample = samples
        ),
    output:
        ksd = f"{path_outdir}/InterSpecific/KSD/Orthogroups.sp.tsv.ks.tsv"
    params:
        outdir = f"{path_outdir}/InterSpecific/KSD"
    threads:
        config["threads"]["inter"]
    conda: "envs/wgd.yaml"
    log: f"{path_outdir}/InterSpecific/KSD/inter_ksd.log"
    shell:
        """
        wgd ksd \
        {input.tsv} \
        {input.fastas} \
        -o {params.outdir} \
        -n {threads} \
        > {log} 2>&1
        """


# ---------------------
# rule interspecific syn

rule inter_syn:
    input:
        tsv = f"{path_outdir}/InterSpecific/DMD/Orthogroups.sp.tsv",
        ksd = f"{path_outdir}/InterSpecific/KSD/Orthogroups.sp.tsv.ks.tsv",
        gff = expand("Scripts/{sample}/{sample}_prefixed.gff", sample = samples),
    output:
        syn = f"{path_outdir}/InterSpecific/SYN/iadhore-out/anchorpoints.txt"
    params:
        dotsize = config["inter_syn"]["dotsize"],
        mingenenum = config["inter_syn"]["mingenenum"],
        outdir = f"{path_outdir}/InterSpecific/SYN",
    threads: config["threads"]["inter"]
    conda: "envs/wgd.yaml"
    log: f"{path_outdir}/InterSpecific/SYN/inter_syn.log"
    shell:
        """
        wgd syn \
        {input.tsv} \
        -ks {input.ksd} \
        --dotsize {params.dotsize} \
        --mingenenum {params.mingenenum} \
        -o {params.outdir} \
        -n {threads} \
        > {log} 2>&1
        """

# ---------------------
# rule interspecific viz for statistics

rule inter_viz:
    input:
        ksd =
        focal =
        anchors =
        tree =
    output:
        viz = f"{path_outdir}/InterSpecific/VIZ"
    params:
        outdir = f"{path_outdir}/InterSpecific/VIZ/All_pairs.ks.node.weighted.pdf"
    threads: config["threads"]["inter"]
    conda: "envs/wgd.yaml"
    log: f"{path_outdir}/InterSpecific/VIZ/inter_viz.log"