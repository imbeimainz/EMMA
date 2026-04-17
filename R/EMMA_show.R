#' EMMA_show
#' 
#' This function displays a human-readable summary of the `EMMA_record` attribute
#' attached to a result object produced by `EMMA_run()`
#' @param res A functional enrichment analysis results object as returned by
#' `EMMA_run()`
#'
#' @returns Returns `base::invisible()`
#' @export
#'
#' @examples
#' data("de_res_IFNg_vs_naive", package = "EMMA")
#' data("universe", package = "EMMA")
#' library("clusterProfiler")
#' res <- EMMA_run(enrichGO(gene = rownames(de_res_IFNg_vs_naive),
#' universe = universe, keyType = "ENSEMBL", OrgDb = org.Hs.eg.db::org.Hs.eg.db,
#' ont = "BP"))
#' EMMA_show(res)
EMMA_show <- function(res){
  if ("EMMA_record" %in% names(attributes(res))) {
    message("Found EMMA record!!")
    emma_rec <- attr(res, "EMMA_record")
    
    if (is.list(res) && "result" %in% names(res)) {
      
      cat("Number of Pathways: ", NROW(res$result), "\n")
    } else {
      cat("Number of Pathways: ", NROW(res), "\n")
    }
    
    method_info <- emma_rec$method
    db_info <- emma_rec$annotation
    
    cat("Call: ", paste(deparse(method_info$call), collapse = " "), " \n")
    cat("Package: ", paste(method_info$package_name , "v.",
                           method_info$package_version), " \n")
    cat("Organism : ", db_info$organism, " \n")
    cat("Gene set library : ", paste(db_info$gene_set_db, collapse = ", "), " \n")
    cat("Gene set library version : ",db_info$gene_set_db_version, " \n")
    cat("\n")
    
  } else {
    warning("No `EMMA_record` attribute was found")
  }
  
  invisible()
  
}
