test_that("EMMA_show", {
  
  fea_res <- data.frame(ID = "term1")
  
  expect_warning(EMMA_show(fea_res))
  
  
  res <- data.frame(ID = c("term1", "term2"))
  
  attr(res, "EMMA_record") <- list(
    method = list(
      call = substitute(fake_enrich(gene = genes)),
      wrapper = FALSE,
      package_name = "fakepkg",
      package_version = "1.0.0"
    ),
    annotation = list(
      organism = "Homo sapiens",
      gene_set_db = "GO",
      gene_set_db_version = "3.22.0"
    )
  )
  
  expect_message(
    expect_output(
      EMMA_show(res),
      "Number of Pathways"
    ),
    "Found EMMA record"
  )
  
  expect_output(EMMA_show(res), "Package")
  expect_output(EMMA_show(res), "Organism")
  expect_output(EMMA_show(res), "Gene set library")
  
  
  fea2 <- list(fea_res,
               res)
  
  attr(fea2, "EMMA_record") <- list(
    method = list(
      call = substitute(fake_enrich(gene = genes)),
      wrapper = TRUE,
      package_name = NA,
      package_version = NA
    ),
    annotation = list(
      organism = "Homo sapiens",
      gene_set_db = "KEGG",
      gene_set_db_version = NA
    )
  )
  expect_output(EMMA_show(fea2), "Number of FEAs:  2")
  expect_output(EMMA_show(fea2), "- FEA_1")
  expect_output(EMMA_show(fea2),"FEA_2")
  
  
  fea_gost <- fea2
  names(fea_gost)[2] <- "result"
  
  attr(fea_gost, "EMMA_record") <- list(
    method = list(
      call = substitute(gost(query = de_res_IFNg_vs_naive$SYMBOL,
                             organism = "hsapiens",
                             correction_method = "fdr",
                             custom_bg = gene_universe,
                             sources = "GO:BP")),
      wrapper = FALSE,
      package_name = "gprofiler2",
      package_version = NA
    ),
    annotation = list(
      organism = "Homo sapiens",
      gene_set_db = "GO",
      gene_set_db_version = NA
    )
  )
  
  expect_output(EMMA_show(fea_gost), "Number of Pathways:  2")
  
  
})
