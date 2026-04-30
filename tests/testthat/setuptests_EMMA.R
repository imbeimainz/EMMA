suppressPackageStartupMessages({
  library("clusterProfiler")
  library("org.Hs.eg.db")
  library("mosdef")
  library("topGO")
  library("gprofiler2")
})

data("de_res_IFNg_vs_naive", package = "EMMA")
data("universe", package = "EMMA")

