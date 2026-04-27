test_that("getEMMARecord", {
  fea_res <- EMMA_run(enrichGO(gene = rownames(de_res_IFNg_vs_naive),
                               keyType = "ENSEMBL",
                               OrgDb = org.Hs.eg.db,
                               pAdjustMethod = "BH",
                               pvalueCutoff = 0.05,
                               qvalueCutoff = 0.1,
                               universe = universe,
                               readable = TRUE))
  
  expect_true(is.list(getEMMARecord(fea_res)))
  expect_length(getEMMARecord(fea_res), 7)
  
  fea_no_emma <- mosdef::run_cluPro(de_genes = 
                                      rownames(de_res_IFNg_vs_naive),
                                    bg_genes = universe,
                                    mapping = "org.Hs.eg.db",
                                    keyType = "ENSEMBL",
                                    ont = "BP",
                                    pAdjustMethod = "BH")
  
  expect_error(getEMMARecord(fea_no_emma))
  
  attr(fea_no_emma, "EMMA_record") <- c()
  
  expect_error(getEMMARecord(fea_no_emma))
  
})