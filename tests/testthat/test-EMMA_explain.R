test_that("EMMA_explain", {
  res <- data.frame(ID = "GO:0000001")
  
  attr(res, "EMMA_record") <- list(
    method = list(
      function_name = "enrichGO",
      package_name = "clusterProfiler",
      package_version = "4.10.0",
      wrapper = FALSE
    ),
    input = list(
      arguments = list(
        gene = c("g1", "g2"),
        universe = c("g1", "g2", "g3", "g4"),
        pAdjustMethod = "BH"
      )
    ),
    annotation = list(
      gene_set_db = "GO",
      gene_set_db_version = "3.18.0"
    )
  )
  
  expect_message(
    txt <- EMMA_explain(res),
    "You can always complete your text"
  )
  
  expect_match(txt, "Functional Enrichment Analysis was performed using the enrichGO\\(\\) function")
  expect_match(txt, "from the clusterProfiler package")
  expect_match(txt, "with the GO database")
  expect_match(txt, "A custom background gene set was provided \\(n = 4\\)")
  expect_match(txt, "Multiple testing correction was performed using the BH method")
  expect_false(grepl("NA", txt))
  
  de_res <- de_res_IFNg_vs_naive[!(is.na(de_res_IFNg_vs_naive$padj)) & de_res_IFNg_vs_naive$padj <= 0.05, ]
  
  
  res_topGO <- run_topGO(de_genes = rownames(de_res),
                         bg_genes = universe,
                         ontology = "BP",
                         gene_id = "ENSEMBL",
                         mapping = "org.Hs.eg.db",
                         add_gene_to_terms = TRUE,
                         do_padj = TRUE) |> EMMA_run()
  
  expect_message(
    txt <- EMMA_explain(res_topGO),
    "You can always complete your text"
  )
  
  expect_match(txt,
               "Functional Enrichment Analysis was performed using a wrapper function run_topGO\\(\\)")
  
  expect_match(txt,"Multiple testing correction was applied")
  
})
