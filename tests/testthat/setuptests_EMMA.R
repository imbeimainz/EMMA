suppressPackageStartupMessages(
  library("clusterProfiler")
)

suppressPackageStartupMessages(
  library("org.Hs.eg.db")
)

suppressPackageStartupMessages(
  library("mosdef")
)

data("de_res_IFNg_vs_naive", package = "EMMA")
data("universe", package = "EMMA")

