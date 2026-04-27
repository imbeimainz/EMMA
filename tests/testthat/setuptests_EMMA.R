invisible(lapply(
  c("clusterProfiler", "org.Hs.eg.db", "mosdef", "topGO", "gprofiler2"),
  function(pkg) suppressPackageStartupMessages(
    library(pkg, character.only = TRUE))
))

data("de_res_IFNg_vs_naive", package = "EMMA")
data("universe", package = "EMMA")

