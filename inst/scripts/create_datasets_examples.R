library("macrophage")
library("DESeq2")

data(gse, "macrophage")
dds_macrophage <- DESeqDataSet(gse, design = ~ line + condition)
rownames(dds_macrophage) <- substr(rownames(dds_macrophage), 1, 15)
dds_macrophage

# DE run
# set seed for reproducibility
set.seed(2711)
# sample randomly for 2k genes
selected_genes <- sample(rownames(dds_macrophage), 500)

dds_macrophage <- dds_macrophage[selected_genes, ]

dds_macrophage <- DESeq(dds_macrophage)

# de res
IFNg_vs_naive <- results(dds_macrophage,
                         contrast = c("condition", "IFNg", "naive"),
                         lfcThreshold = 1, alpha = 0.05)

IFNg_vs_naive <- lfcShrink(dds_macrophage, coef = "condition_IFNg_vs_naive",
                           res = IFNg_vs_naive,
                           type = "apeglm")
summary(IFNg_vs_naive)
IFNg_vs_naive$SYMBOL <- rowData(dds_macrophage)$SYMBOL
IFNg_vs_naive

de_res_IFNg_vs_naive <- as.data.frame(IFNg_vs_naive)
de_res_IFNg_vs_naive <- de_res_IFNg_vs_naive[order(de_res_IFNg_vs_naive$padj), ]
de_res_IFNg_vs_naive <- de_res_IFNg_vs_naive[!(is.na(de_res_IFNg_vs_naive$padj)) &
                                               de_res_IFNg_vs_naive$padj <= 0.05, ]

# define gene universe
gene_universe <- rownames(dds_macrophage)


# perform FEA
library("gprofiler2")
fea_res <- gprofiler2::gost(query = de_res_IFNg_vs_naive$SYMBOL,
                            organism = "hsapiens",
                            correction_method = "fdr",
                            custom_bg = universe,
                            sources = "GO:BP") |> EMMA_run(
                              store_session_info = FALSE,
                              args_form = "unevaluated")

save(de_res_IFNg_vs_naive, file = "de_res_IFNg_vs_naive.RData", compress = "xz")
save(universe, file = "universe.RData", compress = "xz")
save(fea_res, file = "fea_res.RData", compress = "xz")

