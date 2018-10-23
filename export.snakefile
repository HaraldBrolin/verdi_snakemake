# author: Harald Brolin
# date: 2018-10-15
# contact: harald.brolin@wlab.gu.se
#
# Description:
# This script is used to export the qiime2 artifacts like the feature_table.qza
# and the phylogenetic tree

# version: Qiime2 v.2018.8

configfile: "verdi_config.yaml"

rule all:
    input:
        directory("../../data/processed/biom_table"),
        directory("../../data/processed/tree")

rule export_feature_table:
    input:
        table = "../../data/interim/artifacts/dada2/table.qza"
    output:
        biom_table = directory("../../data/processed/biom_table")
    run:
        shell(
            "qiime tools export"
            " --input-path {input.table}"
            " --output-path {output.biom_table}")


rule export_phylo_tree:
    input:
        un_rooted_tree = "../../data/interim/artifacts/phylo_tree/tree.qza"
    output:
        nwk_tree = directory("../../data/processed/tree")
    run:
        shell(
            "qiime tools export"
            " --input-path {input.un_rooted_tree}"
            " --output-path {output.nwk_tree}")
