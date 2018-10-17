# author: Harald Brolin
# date: 2018-10-15
# contact: harald.brolin@wlab.gu.se
#
# Description:
# This scripts is intended to import 16S demultiplexed paired-end read
# using the Phred33 quality score.

# version: Qiime2 v.2018.8


configfile: "verdi_config.yaml"

rule all:
    input:
        directory("../../data/interim/artifacts/dada2"),
        "../../data/visualizations/quality_profiles.qzv"

#expand("../../data/interim/artifacts/{run}paired_end_demux.qza", run=config['run_name'])

# This rule imports the paired-end samples based on a manifest file, see input.
# Since we are impporting paired end each sample needs to have two sampels
# R1 and R2, forward and reverseself. A manifest file is also required specifying
# the sample name, path to sample and direction (forward or reverse), see below:
#
# sample-id,absolute-filepath,direction
# sample-1,$PWD/some/filepath/sample1_R1.fastq,forward
# sample-1,$PWD/some/filepath/sample1_R2.fastq,reverse


#####
#####If statement to check if the reads are Paired end or single end?
#####

rule paired_end_import:
    input:
        "manifest_test"
    output:
        "../../data/interim/artifacts/paired_end_demux.qza"
    run:
        shell(
            "qiime tools import "
            "--type 'SampleData[PairedEndSequencesWithQuality]' "
            "--input-path {input} "
            "--output-path {output} "
            "--input-format PairedEndFastqManifestPhred33")

# After importing the reads we are interested in seeing the quality profeiles of
# the samples, the script bellow generates a summary of the imported demultiplexed
# reads. This allows you to determine how many sequences were obtained per sample,
# and also to get a summary of the distribution of sequence qualities at each
# position in your sequence data.



rule quality_profiles:
    input:
        rules.paired_end_import.output
    output:
        "../../data/visualizations/import/quality_profiles.qzv"
    run:
        shell(
            "qiime demux summarize "
            "--i-data {input} "
            "--o-visualization {output}")

# !!!!! Important !!!!!
# Befor filtering look at the output of the quality_profiles (quality_profiles.qzv)
# to evaluate the correct forward and reverse trunc lengths.

# DADA2 is a pipeline for detecting and correcting (where possible) Illumina
# amplicon sequence data. This quality control process will additionally filter
# any eads that are identified in the sequencing data, and will filter chimeric sequences.

# params: more information about the paramters can be found in the configfile

rule dada2_denoise_paired:
    input:
        rules.paired_end_import.output
    output:
        directory("../../data/interim/artifacts/dada2")
    params:
        truncf = config['trunc-len-f'],
        truncr = config['trunc-len-r']
    threads:
        threads = config['threads']
    run:
        shell(
            "qiime dada2 denoise-paired "
            "--i-demultiplexed-seqs {input} "
            "--p-trunc-len-f {params.truncf} "
            "--p-trunc-len-r {params.truncr} "
            "--p-n-threads {threads} "
            "--output-dir {output}")

#   Generate a tabular view of Metadata. The output visualization supports
#   interactive filtering, sorting, and exporting to common file formats.

rule dada2_metadata_tabulate:
    input:
        "../../data/interim/artifacts/dada2/stats-dada2.qza" ########### FIX RHIS
    output:
        "../../data/visualizations/dada2/quality_profiles.qzv"
    run:
        shell(
            "qiime metadata tabulate "
            "--m-input-file {input} "
            "--o-visualization {output}"
