test_that("EMMA_run", {
  
  fea_res <- EMMA_run(enrichGO(gene = rownames(de_res_IFNg_vs_naive),
                               keyType = "ENSEMBL",
                               OrgDb = org.Hs.eg.db,
                               pAdjustMethod = "BH",
                               pvalueCutoff = 0.05,
                               qvalueCutoff = 0.1,
                               universe = universe,
                               readable = TRUE))
  expect_s4_class(fea_res, "enrichResult")
  
  expect_true("EMMA_record" %in% names(attributes(fea_res)))
  
  expect_true(is.list(attr(fea_res, "EMMA_record")))
  
  expect_true(length(attr(fea_res, "EMMA_record")) == 7)
  
  expect_error(EMMA_run(enrichGO,gene = rownames(de_res_IFNg_vs_naive),
                        keyType = "ENSEMBL",
                        OrgDb = org.Hs.eg.db,
                        pAdjustMethod = "BH",
                        pvalueCutoff = 0.05,
                        qvalueCutoff = 0.1,
                        universe = universe,
                        readable = TRUE))
  
  expect_error(EMMA_run("enrichGO(gene = rownames(de_res_IFNg_vs_naive),
                        keyType = 'ENSEMBL',
                        OrgDb = org.Hs.eg.db)"))
  
  expect_error(EMMA_run(gene = rownames(de_res_IFNg_vs_naive),
                        keyType = "ENSEMBL",
                        OrgDb = org.Hs.eg.db,
                        pAdjustMethod = "BH",
                        pvalueCutoff = 0.05,
                        qvalueCutoff = 0.1,
                        universe = universe,
                        readable = TRUE))
  
  expect_warning(EMMA_run(enrichGO(gene = rownames(de_res_IFNg_vs_naive),
                          keyType = "ENSEMBL",
                          OrgDb = org.Hs.eg.db,
                          pvalueCutoff = 0.05,
                          qvalueCutoff = 0.1,
                          universe = universe,
                          readable = TRUE)))
  
  expect_warning(EMMA_run(enrichGO(gene = rownames(de_res_IFNg_vs_naive),
                          keyType = "ENSEMBL",
                          OrgDb = org.Hs.eg.db,
                          pvalueCutoff = 0.05,
                          qvalueCutoff = 0.1,
                          pAdjustMethod = "BH",
                          readable = TRUE)))
  
})


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
  
})


test_that("testing the record content", {
  
  fea_res <- EMMA_run(enrichGO(gene = rownames(de_res_IFNg_vs_naive),
                               keyType = "ENSEMBL",
                               OrgDb = org.Hs.eg.db,
                               pAdjustMethod = "BH",
                               pvalueCutoff = 0.05,
                               qvalueCutoff = 0.1,
                               universe = universe,
                               readable = TRUE))
  
  emma_rec <- attr(fea_res, "EMMA_record")
  
  org <- emma_rec$annotation$organism
  
  db <- emma_rec$annotation$gene_set_db
  
  expect_true(is.list(emma_rec$annotation))
  expect_true(is.list(emma_rec$method))
  expect_true(is.list(emma_rec$input))
  
  expect_identical(org, "Homo sapiens")
  expect_identical(db, "GO")
  
  
  
})


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


