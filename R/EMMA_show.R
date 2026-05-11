#' EMMA_show
#' 
#' This function displays a human-readable summary of the `EMMA_record` attribute
#' attached to a result object produced by `EMMA_run()`
#' 
#' @param res A functional enrichment analysis results object as returned by
#' `EMMA_run()`
#'
#' @returns `base::invisible()`
#' @export
#'
#' @examples
#' data("fea_res", package = "EMMA")
#' EMMA_show(fea_res)
EMMA_show <- function(res){
  
  if ("EMMA_record" %in% names(attributes(res))) {
    cli::cli_alert_info("Found EMMA record!")
    
    emma_rec <- EMMA_get_record(res)
    
    if (is.list(res) && !is.data.frame(res)) {
      # e.g. case of gost, returns a list but it's 1 FEA (result)
      if ("result" %in% names(res)) {
        cat("Number of Pathways: ", NROW(res$result), "\n")
      } else {
        # let's say if we have of list of FEAs (returned by custom function)
        cat("Number of FEAs: ", length(res), "\n")
        
        nms <- names(res)
        if (is.null(nms) || any(nms == "")) {
          nms <- paste0("FEA_", seq_along(res))
        }
        
        for (i in seq_along(res)) {
          # check the number of pathways for each element of the list
          cat(" -", nms[i], ": ", NROW(res[[i]]), " pathways\n")
        }
      }
    } else {
      cat("Number of Pathways: ", NROW(res), "\n")
    }
    
    method_info <- emma_rec$method
    db_info <- emma_rec$annotation
    
    cat("Call: ", paste(deparse(method_info$call), collapse = " "), " \n")
    cat("Wrapper: ", method_info$wrapper, " \n")
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
