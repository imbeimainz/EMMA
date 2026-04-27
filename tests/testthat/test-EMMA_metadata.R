test_that("test metadata content & structure", {
  
  fea_res <- EMMA_run(mosdef::run_cluPro(de_genes = 
                                           rownames(de_res_IFNg_vs_naive),
                                         bg_genes = universe,
                                         mapping = "org.Hs.eg.db",
                                         keyType = "ENSEMBL",
                                         ont = "BP",
                                         pAdjustMethod = "BH"))
  
  emma_rec <- attr(fea_res, "EMMA_record")
  
  org <- emma_rec$annotation$organism
  
  db <- emma_rec$annotation$gene_set_db
  
  expect_true(is.list(emma_rec$annotation))
  expect_true(is.list(emma_rec$method))
  expect_true(is.list(emma_rec$input))
  
  expect_identical(org, "Homo sapiens")
  expect_identical(db, "GO")
  
  expect_true(emma_rec$method$wrapper)
  
  expect_null(EMMA_find_original_wrapped_fun("mosdef::run_cluPro(de_genes = rownames(de_res_IFNg_vs_naive),
                                                                bg_genes = universe,
                                                                mapping = 'org.Hs.eg.db',
                                                                keyType = 'ENSEMBL',
                                                                ont = 'BP')"))
  
  
  custom <- EMMA_classify_call(substitute(summary(getEMMARecord(fea_res))))
  
  expect_equal(custom$type, "custom")
  
  
  expect_warning(res <- EMMA_run(mosdef::run_goseq(de_genes = rownames(de_res_IFNg_vs_naive),
                                   bg_genes = universe,
                                   mapping = "org.Hs.eg.db",
                                   id = "ensGene",
                                   genome = "hg19")))
  
  
  res <- EMMA_add_custom_metadata(res,
                                  extra = list(
                                    note = "The background gene set list was all expressed genes in the assay"))
  
  rec <- getEMMARecord(res)
  
  expect_equal(
    rec$extra$note,
    "The background gene set list was all expressed genes in the assay"
  )
  
  expect_null(rec$extra$notfoud)
  
  expect_error(res <- EMMA_add_custom_metadata(res,
                                               extra = list("The background gene set list was all expressed genes in the assay"))
  )
  
  expect_error(res <- EMMA_add_custom_metadata(res,
                                               extra = "The background gene set list was all expressed genes in the assay"))
  
  
  fea_res <- gprofiler2::gost(query = de_res_IFNg_vs_naive$SYMBOL,
                              organism = "hsapiens",
                              correction_method = "fdr",
                              custom_bg = universe) |> EMMA_run()
  
  rec <- getEMMARecord(fea_res)
  
  expect_true(length(rec$annotation$gene_set_db_version) != 1)
  
  
  custom_fun <- function(gene, OrgDb) {
    clusterProfiler::groupGO(
      gene = gene,
      OrgDb = OrgDb,
      keyType = "ENSEMBL",
      ont = "BP",
      level = 2,
      readable = FALSE
    ) 
  }
  
  expect_warning(wrapper <- EMMA_run(custom_fun(rownames(de_res_IFNg_vs_naive),
                                                org.Hs.eg.db)))

  expect_equal(getEMMARecord(wrapper)$method$function_name, "custom_fun")
  expect_equal(getEMMARecord(wrapper)$method$wrapped_package, "clusterProfiler")
  expect_equal(getEMMARecord(wrapper)$method$wrapped_function, "groupGO")
  expect_true(getEMMARecord(wrapper)$method$wrapper) 

  
  empty <- EMMA_run(summary(rec$method))
  
  expect_null(getEMMARecord(empty)$annotation$organism)
  expect_null(getEMMARecord(empty)$annotation$gene_set_db)
  expect_null(getEMMARecord(empty)$annotation$gene_set_db_version)
  
  
})


