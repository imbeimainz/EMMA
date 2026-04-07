#' EMMA_show
#' 
#' This function prints the EMMA record associated with a functional enrichment
#' analysis object, including the executed call, parameters, and provenance
#' information.
#' @param res A functional enrichment analysis results object as returned by
#' `EMMA_run()`
#'
#' @returns NULL
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
    if (!is.list(emma_rec)) {
      stop("'EMMA_record' must be a list!")
    }
    
    if (is.list(res) && "result" %in% names(res)) {
      
      cat("Number of Pathways: ", NROW(res$result), "\n")
    } else {
      cat("Number of Pathways: ", NROW(res), "\n")
    }
    
    pkg_info <- emma_rec$method
    db_info <- emma_rec$annotation
    
    cat("Call: ", paste(deparse(emma_rec$call), collapse = " "), " \n")
    cat("Package: ", paste(pkg_info$package_name , "v.",
                           pkg_info$package_version), " \n")
    cat("Organism : ", db_info$organism, " \n")
    cat("Gene set library : ", paste(db_info$gene_set_db, collapse = ", "), " \n")
    cat("Gene set library version : ",db_info$gene_set_db_version, " \n")
    cat("\n")
    
  } else {
    warning("No `EMMA_record` attribute was found")
  }
  
}
