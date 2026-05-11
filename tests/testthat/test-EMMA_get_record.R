test_that("EMMA_get_record", {
  expect_true(is.list(EMMA_get_record(fea_res)))
  expect_length(EMMA_get_record(fea_res), 7)
  
  fea_no_emma <- mosdef::run_cluPro(de_genes = 
                                      rownames(de_res_IFNg_vs_naive),
                                    bg_genes = universe,
                                    mapping = "org.Hs.eg.db",
                                    keyType = "ENSEMBL",
                                    ont = "BP",
                                    pAdjustMethod = "BH")
  
  expect_error(EMMA_get_record(fea_no_emma))
  
  attr(fea_no_emma, "EMMA_record") <- c()
  
  expect_error(EMMA_get_record(fea_no_emma))
  
  expect_error(EMMA_get_record("guiga"))
  
  attr(fea_res, "EMMA_record") <- NULL
  expect_error(EMMA_get_record(fea_res))
  
  attr(fea_res, "EMMA_record") <- "i am a corrupted rec"
  expect_error(EMMA_get_record(fea_res))
  
})