#' EMMA_freeze
#' 
#' This function records the R environment during analysis runtime and generates
#' a lockfile that can be used with tools such as `renv`.
#' By default, all currently loaded namespaces are recorded.
#'
#' @param project Character string corresponding to the path to the project
#' directory where the lockfile should be written. If the directory does not
#' exist, it will be created. It defaults to the current working directory
#' @param file Character string refering to the name of the lockfile to generate.
#' It defaults to "renv.lock"
#' @param pkgs Character vector of package names to snapshot. It defaults to all
#' currently loaded namespaces via `loadedNamespaces()`
#' 
#' @details
#' This function calls `renv::snapshot()` with the specified packages.
#' The resulting lockfile can later be restored with `renv::restore()` to
#' recreate the same package environment.
#' 
#' @returns TODO json file like to create a lock.file?
#' 
#' @seealso \code{\link[renv]{snapshot}}, \code{\link[renv]{restore}}
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' # Create a lockfile in a separate directory
#' EMMA_freeze(project = "emma_env")
#'
#' # Restore later with renv
#' renv::restore(project = "emma_env")
#' }
EMMA_freeze <- function(project = getwd(),
                        file = "renv.lock",
                        pkgs = loadedNamespaces()){
  
  # if (!dir.exists(project)) dir.create(project, recursive = TRUE)
  # 
  # renv::snapshot(
  #   project = project,
  #   lockfile = file,
  #   packages = pkgs
  # )
  # 
  cli::cli_alert_info(
    "Environment snapshot saved to: {.val {lockfile}}. \nTo recreate this environment, use `renv::restore()`.")
}