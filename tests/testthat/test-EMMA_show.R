test_that("EMMA_show", {
  
  fea_res <- enrichGO(gene = rownames(de_res_IFNg_vs_naive),
                      keyType = "ENSEMBL",
                      OrgDb = org.Hs.eg.db,
                      pAdjustMethod = "BH",
                      pvalueCutoff = 0.05,
                      qvalueCutoff = 0.1,
                      universe = universe,
                      readable = TRUE)
  
  
  expect_warning(EMMA_show(fea_res))
})