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
        directory("../../data/visualizations/alpha_rarefaction"),
        directory("../../data/interim/artifacts/core_metrics_phylogeny")

#

rule core_metrics_phylogeny:
    input:
        rooted_tree = "../../data/interim/artifacts/phylo_tree/rooted_tree.qza",
        table = "../../data/interim/artifacts/dada2/table.qza",
        meta_data = "../../src/data/meta_data_test.txt"
    output:
        directory("../../data/interim/artifacts/core_metrics_phylogeny") ######## Here fix the output
        # faith_pd = "../../data/interim/artifacts/core_metrics_phylogeny/faith_pd.qza",
        # observed = "../../data/interim/artifacts/core_metrics_phylogeny/observed.qza",
        # shannon = "../../data/interim/artifacts/core_metrics_phylogeny/shannon.qza",
        # pielou_eveness = "../../data/interim/artifacts/core_metrics_phylogeny/pielou_eveness.qza",
        # unweighted_unifrac = "../../data/interim/artifacts/core_metrics_phylogeny/unweighted_unifrac.qza",
        # weighted_unifrac = "../../data/interim/artifacts/core_metrics_phylogeny/weighted_unifrac.qza",
        # jaccard = "../../data/interim/artifacts/core_metrics_phylogeny/jaccard.qza",
        # bray_curtis = "../../data/interim/artifacts/core_metrics_phylogeny/bray_curtis.qza",

    params:
        sampling_depth = config['sampling_depth']
    threads:
        threads = config['threads']
    run:
        shell(
            "qiime diversity core-metrics-phylogenetic"
            " --i-phylogeny {input.rooted_tree}"
            " --i-table {input.table}"
            " --p-sampling-depth {params.sampling_depth}"
            " --m-metadata-file {input.meta_data}"
            # " --o-faith-pd-vector {input.faith_pd}"                    # Alpha-diversity
            # " --o-observed-otus-vector {input.observed}"
            # " --o-shannon-vector {input.shannon}"
            # " --o-evenness-vector {input.pielou_eveness}"   # Pielou
            # " --o-unweighted-unifrac-distance-matrix {input.unweighted_unifrac}" # Beta-diversity
            # " --o-weighted-unifrac-distance-matrix {input.weighted_unifrac}"
            # " --o-jaccard-distance-matrix {input.jaccard}"
            # " --o-bray-curtis-distance-matrix {input.bray_curtis}")
            " --output-dir {output}")

#

rule alpha_rarefaction:
    input:
        rooted_tree = "../../data/interim/artifacts/phylo_tree/rooted_tree.qza",
        table = "../../data/interim/artifacts/dada2/table.qza",
        meta_data = "../../src/data/meta_data_test.txt"
    output:
        directory("../../data/visualizations/alpha_rarefaction")
    params:
        max_depth = config['max_depth'],
        min_depth = config['min_depth'],
        steps = config['steps']
    run:
        shell(
            "qiime diversity alpha-rarefaction"
            " --i-phylogeny {input.rooted_tree}"
            " --i-table {input.table}"
            " --p-max-depth {params.max_depth}"
            " --p-min-depth {params.min_depth}"
            " --p-steps {params.steps}"
            " --m-metadata-file {input.meta_data}"
            " --output-dir {output}")
