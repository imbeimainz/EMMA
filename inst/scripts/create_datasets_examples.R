library("macrophage")
library("DESeq2")

data(gse, "macrophage")
dds_macrophage <- DESeqDataSet(gse, design = ~ line + condition)
rownames(dds_macrophage) <- substr(rownames(dds_macrophage), 1, 15)
dds_macrophage

# DE run
keep <- rowSums(counts(dds_macrophage) >= 10) >= 6
dds_macrophage <- dds_macrophage[keep, ]
dds_macrophage


# set seed for reproducibility
set.seed(42)
# sample randomly for 2k genes
selected_genes <- sample(rownames(dds_macrophage), 2000)

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

universe <- rownames(dds_macrophage)

save(de_res_IFNg_vs_naive, file = "de_res_IFNg_vs_naive.RData", compress = "xz")
save(universe, file = "universe.RData", compress = "xz")



