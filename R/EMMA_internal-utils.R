# metadata capture -------------------------------------------------------------
#' get the basic structure for the metadata elements to be captured depending on
#' the method
#' 
#' @noRd
EMMA_empty_metadata <- function() {
  list(
    organism = NA_character_,
    gene_set_db = NA_character_,
    gene_set_db_version = NA_character_
  )
}

#' depending on the function/pkg, decide the right function dispatch
#'
#' @param function_name A character string specifying the function name used to
#' perform FEA
#' @param package_name A character string containing the package name used to
#' perform FEA
#' @param args A list containing the evaluated arguments passed into the
#' function call to perform FEA 
#'
#' @noRd
EMMA_get_metadata <- function(function_name,
                               package_name,
                               args) {
  switch(
    package_name,
    clusterProfiler = EMMA_get_clusterprofiler_metadata(function_name, args),
    gprofiler2      = EMMA_get_gprofiler2_metadata(args),
    mosdef          = EMMA_cp_GO_metadata(args$mapping),
    EMMA_empty_metadata()
  )
}

#' get metadata from clusterProfiler functions
#' @param function_name A character string specifying the function name used to
#' perform FEA
#'
#' @param args A list containing the evaluated arguments passed into the
#' function call to perform FEA 
#'
#' @noRd
EMMA_get_clusterprofiler_metadata <- function(function_name, args) {
  switch(
    function_name,
    enrichGO   = EMMA_cp_GO_metadata(args$OrgDb),
    gseGO = EMMA_cp_GO_metadata(args$OrgDb),
    groupGO = EMMA_cp_GO_metadata(args$OrgDb),
    enrichKEGG = EMMA_cp_KEGG_metadata(args),
    gseKEGG = EMMA_cp_KEGG_metadata(args),
    EMMA_empty_metadata()
  )
}

#' extract the organism from org,*.eg.db objects
#' @param orgdb Organism object from org.*.eg.db packages
#'
#' @noRd
EMMA_get_organism_from_OrgDb <- function(orgdb) {
  
  if (is.null(orgdb)) {
    return(NA_character_)
  }
  
  if (is.character(orgdb) && length(orgdb) == 1) {
    if (!exists(orgdb, mode = "S4")) {
      stop(orgdb,
           " was provided as a string, but no loaded object with that name was found. ", 
           "Please load the corresponding org.*.db library")
    }
    orgdb <- get(orgdb)
  }
  
  md <- AnnotationDbi::metadata(orgdb)
  organism <- md$value[md$name == "ORGANISM"]
  
  if (length(organism) != 1L) {
    return(NA_character_)
  }
  return(organism)
}


#' assemble metadata element from clusterProfiler GO analyses
#' 
#' @param org 
#'
#' @noRd
EMMA_cp_GO_metadata <- function(org) {
  meta <- list()
  
  meta$organism <- EMMA_get_organism_from_OrgDb(org)
  meta$gene_set_db <- "GO"
  meta$gene_set_db_version <- if (requireNamespace("GO.db", quietly = TRUE)) {
    as.character(utils::packageVersion("GO.db"))
  } else {
    NA_character_
  }
  
  return(meta)
}


### not tested yet since the kegg server is down and the function couldn't work

#' assemble metadata element from clusterProfiler KEGG analyses
#' 
#' @param args A list containing the evaluated arguments passed into the
#' function call to perform FEA 
#'
#' @noRd
EMMA_cp_KEGG_metadata <- function(args) {
  meta <- list()
  
  meta$organism <- args$organism
  meta$gene_set_db <- "KEGG"
  meta$gene_set_db_version <- NA_character_
  
  return(meta)
}

#' This function assembles annotation metadata from a `gprofiler2` enrichment call
#' 
#' @param args A list containing the evaluated arguments passed into the
#' function call to perform FEA
#' 
#' @return A named list 
#'
#' @noRd
EMMA_get_gprofiler2_metadata <- function(args) {
  meta <- list()
  
  version_info <- gprofiler2::get_version_info()
  
  meta$organism <- if (!is.null(args$organism)) args$organism else NA_character_
  
  sources_used <- if (!is.null(args$sources)) {
    args$sources
  } else {
    names(version_info[["sources"]])
  } 
  
  # in case the source is GO, we extract all the dbs ...
  if ("GO" %in% sources_used) {
    sources_used <- unique(c(
      setdiff(sources_used, "GO"),
      "GO:BP", "GO:CC", "GO:MF"
    ))
  }
  
  meta$gene_set_db <- sources_used
  
  meta$gene_set_db_version <- vapply(
    version_info[["sources"]][sources_used], function(x) x[["version"]],
    character(1)
  ) # needs more work when only GO, no need to print 3 times the same version
  # also, differentiate between which version corresponds to which db

  return(meta)
}

# call capture -----------------------------------------------------------------

#' EMMA_capture_call_info
#' 
#' This function extracts call related metadata. It handles two call
#' formats: bare function calls (e.g. `enrichGO(...)`) and namespace-qualified
#' calls (e.g. `clusterProfiler::enrichGO(...)`).
#'
#' @param call A call object
#' @param envir The environment in which to look up the function when a bare
#' call is used. Defaults to `base::parent.frame()`.
#'
#' @return A named list
#' @noRd
EMMA_capture_call_info <- function(call, envir = parent.frame()) {
  # param checks
  if (!is.call(call)) {
    stop("`call` must be a function call", call. = FALSE)
  }
  # capture function name
  call_name <- call[[1]]
  # when we only use function name e.g. enrichGO(...)
  if (is.symbol(call_name)) {
    function_name <- as.character(call_name)
    fun <- get(function_name, envir = envir, mode = "function")
    pkg <- utils::packageName(environment(fun))
    package_name <- if (is.null(pkg) || pkg == "" ) NA_character_ else pkg
    pkg_version <- if (!is.na(package_name)) {
      as.character(packageVersion(package_name))}
    else NA_character_
    # capture args (unevaluated)
    arg_list <- as.list(call)[-1]

    return(list(
      call = call,
      function_name = function_name,
      package_name = package_name,
      package_version = pkg_version,
      arg_list = arg_list
    ))
  }
  
  # when we use function name with namespace e.g. clusterProfiler::enrichGO(...)
  if (is.call(call_name) &&
      length(call_name) == 3L &&
      identical(call_name[[1]], as.symbol("::"))) {
    package_name <- as.character(call_name[[2]])
    function_name <- as.character(call_name[[3]])
    pkg_version <- if (!is.na(package_name)) {
      as.character(utils::packageVersion(package_name))
    } else {
      NA_character_
    }
    # capture args (unevaluated)
    arg_list <- as.list(call)[-1]
    
    return(list(
      call = call,
      function_name = function_name,
      package_name = package_name,
      package_version = pkg_version,
      arg_list = arg_list
    ))
  }
  
  stop(
    "Unsupported call format. Use a direct function call like `enrichGO(...)` or `pkg::fun(...)`",
    call. = FALSE)
}


# build EMMA record ------------------------------------------------------------

#' EMMA_build_record
#' 
#' This function assembles the structured provenance record that is stored as
#' an attribute on the FEA results object.
#' 
#' @param info_call A list returned by `EMMA_capture_call_info()`
#' @param args_form A character string, either `"evaluated"` or `"unevaluated"`
#' to decide how to store the arguments
#' @param metadata A list returned by `EMMA_get_metadata()`
#' @param start_time A timestamp marking when the enrichment analysis started
#' @param session Logical. If `TRUE`, `sessionInfo()` is captured and stored in
#' the record; if `FALSE` the `session_info` slot is `NULL`
#'  
#' @return A named list of the recorded metadata
#'   
#' @noRd
EMMA_build_record <- function(info_call, args_form, metadata,
                               start_time, session) {
  emma_rec <- list(
                   method = list(
                     call = info_call$call,
                     function_name = info_call$function_name,
                     package_name = info_call$package_name,
                     package_version = info_call$package_version
                   ),
                   input = list(
                     arguments = if (args_form == "evaluated") info_call$args 
                     else info_call$arg_list
                   ),
                   annotation = list(
                     organism = metadata$organism,
                     gene_set_db = metadata$gene_set_db,
                     gene_set_db_version = metadata$gene_set_db_version
                   ),
                   timestamp = start_time,
                   session_info = if (isTRUE(session)) sessionInfo() else NULL,
                   user_metadata = list(),# free form user additions
                   emma_version = as.character(packageVersion(pkg = "EMMA"))
                   )
  
  return(emma_rec)
  
}

# good practice warnings -------------------------------------------------------

#' EMMA_warnings
#' 
#' This function warns about missing good-practice arguments in enrichment calls.
#' A warning is raised if none of the synonyms for a given category appear
#' in `arg_names`
#' 
#' @param arg_names A character vector of argument names as written in the
#' user's call, obtained within `EMMA_run()`
#' @param function_name A character corresponding to the name of the enrichment
#' function called, used only for constructing the warning message
#' 
#' @return `base::invisible()`
#' @noRd
EMMA_warnings <- function(arg_names, function_name){
  checks <- list(
    list(
      params = c("pAdjustMethod", "correction_method", "do_padj"),
      label  = "multiple-testing correction method"
    ),
    list(
      params = c("universe", "background", "custom_bg", "bg_genes"),
      label  = "background gene set"
    )
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
  invisible()
}

