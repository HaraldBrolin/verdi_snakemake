# author: Harald Brolin
# date: 2018-10-15
# contact: harald.brolin@wlab.gu.se
#
# Description:
# This scripts is intended to generate alpha and beta diversity report of the
# 16S data.

# version: Qiime2 v.2018.8


configfile: "verdi_config.yaml"

rule all:
    input:
        "../../data/visualizations/taxonomy/feature_confidence.qzv",
        "../../data/visualizations/taxonomy/taxa_bar_plot.qzv"


rule classify_sklearn:
    input:
        representative_seqs = "../../data/interim/artifacts/dada2/representative_sequences.qza",
        classifier = config['classifier_path']
    output:
        classification = "../../data/interim/artifacts/classification/taxonomy.qza",
    run:
        shell(
            "qiime feature-classifier classify-sklearn"
            " --i-classifier {input.classifier}"
            " --i-reads {input.representative_seqs}"
            " --o-classification {output.classification}")


rule feature_classification_confidence:
    input:
        taxonomy = rules.classify_sklearn.output.classification
    output:
        read_stats = "../../data/visualizations/taxonomy/feature_confidence.qzv"
    run:
        shell(
            "qiime metadata tabulate"
            " --m-input-file {input.taxonomy}"
            " --o-visualization {output.read_stats}")

rule bar_plot:
    input:
        table = "../../data/interim/artifacts/dada2/table.qza",
        taxonomy = rules.classify_sklearn.output.classification,
        meta_data = "../../src/data/meta_data_test.txt"
    output:
        bar_plot = "../../data/visualizations/taxonomy/taxa_bar_plot.qzv"
    run:
        shell(
            "qiime taxa barplot"
            " --i-table {input.table}"
            " --i-taxonomy {input.taxonomy}"
            " --m-metadata-file {input.meta_data}"
            " --o-visualization {output.bar_plot}")
