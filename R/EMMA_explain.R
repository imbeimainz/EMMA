#' EMMA_explain
#'
#' This function generates a human-readable description of the FEA, similar
#' to a Materials and Methods section of a paper, by summarizing the executed
#' call, the parameters, software context, and reference databases used.
#'
#' @param res A functional enrichment analysis results object as returned by
#' `EMMA_run()`. Its attributes contain `EMMA_record`, which contains all 
#' provenance information of the performed FEA
#' @param get_citation Logical indicating whether to display the citations of
#' the packages used in the FEA. It only prints the citations in an interactive
#' session (e.g console). Defaults to `TRUE`
#' @returns A character string describing how the FEA was performed using the
#' recorded metadata 
#' 
#' @export
#' @examples
#' data("fea_res", package = "EMMA")
#' EMMA_explain(fea_res)
#' 
EMMA_explain <- function(res, get_citation = TRUE){
  
  emma_rec <- EMMA_get_record(res)

  function_name <- emma_rec$method$function_name
  pkg_name <- emma_rec$method$package_name
  pkg_version <- emma_rec$method$package_version
  db <- emma_rec$annotation$gene_set_db
  db_version <- emma_rec$annotation$gene_set_db_version

  args <- emma_rec$input$arguments
  arg_names <- names(args)
  
  cli::cli_alert_info(
    "You can always complete your text with additional information from `EMMA_get_record()`!"
  )
  
  
  if (isTRUE(emma_rec$method$wrapper)) {

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
    bg_value <- args[[bg_arg]]
    
    if (length(bg_value) > 1) {
      # evaluated arguments
      text <- paste0(text,
                     " A custom background gene set was provided (n = ",
                     length(bg_value),").")
      
    } else if (length(bg_value) == 1) {
      # unevaluated arguments.
      text <- paste0(text, " A custom background gene set was provided.")
    }
      
  } else {
    text <- paste0(text, " No custom background gene set was recorded.")
  }


  ### info abt the fdr correction
  if (length(fdr_arg) == 1) {
    fdr_value <- args[[fdr_arg]]
    text <- paste0(text,
      " Multiple testing correction was performed using the ",
      fdr_value, " method."
    )
  } else if ("do_padj" %in% arg_names) {
    if (isTRUE(args[["do_padj"]])) {
      text <- paste0(text, " Multiple testing correction was applied.")
    } else if (identical(args[["do_padj"]], FALSE)) {
      text <- paste0(text, " Multiple testing correction was not applied.")
    }
  }

  ### get citations
  
  if (get_citation) {
    pkgs <- unique(stats::na.omit(c(
      emma_rec$method$package_name,
      emma_rec$method$wrapped_package
    )))
    
    if (length(pkgs) > 0L) {
      cli::cli_alert_info("References:")
      for (pkg in pkgs) {
          cli::cli_verbatim(paste(format(utils::citation(pkg)),
                                  collapse = "\n"))
      }
    }
    
  }

  return(text)
}
