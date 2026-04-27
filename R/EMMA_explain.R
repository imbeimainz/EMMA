#' EMMA_explain
#'
#' This function generates a human-readable description of the FEA, similar
#' to a Materials and Methods section of a paper, by summarizing the executed
#' call, the parameters, software context, and reference databases used.
#'
#' @param res A functional enrichment analysis results object as returned by
#' `EMMA_run()`. Its attributes contain `EMMA_record`, which
#' contains all provenance information of the performed FEA
#' @returns A character string describing how the FEA was performed using the
#' recorded metadata
#' @export
#' @examples
#' data("de_res_IFNg_vs_naive", package = "EMMA")
#' data("universe", package = "EMMA")
#' library("clusterProfiler")
#' res <- EMMA_run(enrichGO(gene = rownames(de_res_IFNg_vs_naive),
#' universe = universe, keyType = "ENSEMBL", OrgDb = org.Hs.eg.db::org.Hs.eg.db,
#' ont = "BP", pAdjustMethod = "BH"))
#' EMMA_explain(res)
#' 
EMMA_explain <- function(res){
  
  emma_rec <- getEMMARecord(res)
  
  function_name <- emma_rec$method$function_name
  pkg_name <- emma_rec$method$package_name
  pkg_version <- emma_rec$method$package_version
  db <- emma_rec$annotation$gene_set_db
  db_version <- emma_rec$annotation$gene_set_db_version
  
  args <- emma_rec$input$arguments
  arg_names <- names(args)
  
  message("You can always complete your text with additional information from `getEMMARecord()`!")
  
  if (emma_rec$method$wrapper) {
    text <- paste0("Functional Enrichment Analysis was performed using a wrapper function ",
                   function_name, "()")
  } else {
    text <- paste0("Functional Enrichment Analysis was performed using the ",
                   function_name, "() function")
  }
  
  # checks to avoid text with NA
  if (!is.null(pkg_name) && !is.na(pkg_name)) {
    text <- paste0(text, " from the ", pkg_name, " package")
  }
  
  if (!is.null(pkg_version) && !is.na(pkg_version)) {
    text <- paste0(text, " (version ", pkg_version, ")")
  }
  
  if (!is.null(db) && !all(is.na(db))) {
    text <- paste0(text, " with the ",
                  paste(db, collapse = ", "), " database")
  }
  
  if (!is.null(db_version) && !all(is.na(db_version))) {
    text <- paste0(text, " (version ",
                  paste(db_version, collapse = ", "),")")
  }
  
  text <- paste0(text, ".")
  
  ### info abt bg genes
  bg_arg <- intersect(c("universe", "background", "custom_bg", "bg_genes"),
                      arg_names)
  fdr_arg <- intersect(c("correction_method", "pAdjustMethod"), arg_names)
  
  if (length(bg_arg) == 1) {
      text <- paste0(text,
        " A custom background gene set was provided (n = ",
        length(args[[bg_arg]]),
        ")."
      )
  } else if (length(bg_arg) > 1L) {
    text <- paste0(text, " A custom background gene set was provided.")
  } else {
    text <- paste0(text, " No custom background gene set was recorded.")
  }
  
  
  ### info abt the fdr correction
  if (length(fdr_arg) == 1) {
    text <- paste0(text,
      " Multiple testing correction was performed using the ",
      args[[fdr_arg]], " method."
    )
  } else if ("do_padj" %in% arg_names) {
    if (isTRUE(args[["do_padj"]])) {
      text <- paste0(text, " Multiple testing correction was applied.")
    } else if (identical(args[["do_padj"]], FALSE)) {
      text <- paste0(text, " Multiple testing correction was not applied.")
    }
  }
  
  return(text)
}