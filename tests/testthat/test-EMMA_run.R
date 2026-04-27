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
  
  info <- EMMA_capture_call_info(substitute(enrichGO(gene = rownames(de_res_IFNg_vs_naive),
                                                     keyType = "ENSEMBL",
                                                     OrgDb = org.Hs.eg.db,
                                                     pAdjustMethod = "BH",
                                                     pvalueCutoff = 0.05,
                                                     qvalueCutoff = 0.1,
                                                     universe = universe,
                                                     readable = TRUE)))
  
  expect_type(info, "list")
  expect_length(info, 5)
  expect_length(info$arg_list, 8)
  
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
  
  expect_error(EMMA_run(groupGO(gene = rownames(de_res_IFNg_vs_naive),
                                OrgDb = org.Hs.eg.db,
                                keyType = "ENSEMBL",
                                ont = "CC",
                                level = 2), envir = getwd()))
  
  expect_error(EMMA_run(groupGO(gene = rownames(de_res_IFNg_vs_naive),
                                OrgDb = org.Hs.eg.db,
                                keyType = "ENSEMBL",
                                ont = "CC",
                                level = 2), session = "yes"))
  
})


