#' EMMA_run
#' 
#' This function executes functional enrichment analysis using existing tools
#' and captures the associated parameters and provenance information for the
#' analysis during runtime.
#' @param expr A function call that performs functional enrichment analysis.
#' The call is captured and executed by EMMA to record analysis parameters and
#' provenance information
#' @param envir An environment in which to evaluate `expr`
#'
#' @returns Functional enrichment analysis results in the native format
#' returned by the original `expr`
#' @export
#'
#' @examples
#' EMMA_run(enrichGO(gene = rownames(de_res_IFNg_vs_naive), universe = universe, keyType = "ENSEMBL", OrgDb = org.Hs.eg.db, ont = "BP"))
EMMA_run <- function(expr, envir = parent.frame()) {
  
  # capture call
  call <- substitute(expr)
  
  # param checks
  if (!is.call(call)) {
    stop("`expr` must be a function call, e.g. enrichGO(...)!")
  }

  # capture function name
  function_name <- paste(deparse(call[[1]]), collapse = "")
  
  # capture args (unevaluated)
  arg_list <- as.list(call)[-1]
  
  arg_names <- names(arg_list)
  
  # now we'll put some warning on important args if
  # the user did not define them (like the fdr correction ...)
  
  checks <- list(
    list(params = c("pAdjustMethod", "correction_method"),
         label  = "multiple-testing correction method"),
    list(params = c("universe", "background"),
         label  = "background gene set")
    )
  
  
  for (check in checks) {
    if (!any(check$params %in% arg_names)) {
      warning(
        sprintf(
          "No %s was specified for %s(). 
Consider using the corresponding parameter for your call.",
          check$label,
          function_name
        ),
        call. = FALSE
      )
    }
  }
  
  # maybe warn when the organism and the gene names dont match? like u have 
  # mouse data but u defined organism as human
  
  #capture analysis time
  start_time <- Sys.time()
  message("Running Enrichment Analysis with ", function_name, " ...") # maybe we can print the list of arg used also in the msg?
  
  # capture the value of the arguments
  args <- lapply(arg_list, eval, envir = envir)
  
  # get the function
  fun <- eval(call[[1]], envir = envir)
  
  # run the analysis
  results <- do.call(fun, args)
  
  # capture pkg used
  enrich_function <- match.fun(function_name)
  pkg <- environmentName(environment(enrich_function))

  
  # store everything
  EMMA_record <- list(
    call = call,
    package = pkg,
    package_version = if (!is.na(pkg)) 
      as.character(packageVersion(pkg)) else NA,
    arguments = args,
    gene_set_library = NA, #placeholder
    gene_set_library_version = NA,
    organism = NA,
    runtime = start_time, 
    session = sessionInfo()
  )
  
  # store the emma records as attribute of the results obj
  attr(results, "EMMA_record") <- EMMA_record
  
  return(results)
}
