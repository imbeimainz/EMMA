# EMMA_run

This function executes any functional enrichment analysis function and
attaches a provenance record (`EMMA_record`) describing the analysis.
The captured record includes the original call, metadata derived from
the call and its arguments, runtime information, and optionally the
current session information.

## Usage

``` r
EMMA_run(
  expr,
  envir = parent.frame(),
  store_session_info = TRUE,
  args_form = c("evaluated", "unevaluated")
)
```

## Arguments

- expr:

  A function call that performs functional enrichment analysis. The call
  is captured and executed by EMMA to record analysis parameters and
  provenance information. Both bare calls (`enrichGO(...)`) and
  namespace-qualified calls (`clusterProfiler::enrichGO(...)`) are
  supported.

- envir:

  An environment in which to evaluate `expr`

- store_session_info:

  Logical, indicating whether to store the output of
  [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) or not. If
  `TRUE` (default), the session is stored in the provenance record

- args_form:

  A character string indicating whether to store the evaluated or the
  unevaluated arguments in the provenance record. It default to
  `"evaluated"`

## Value

The result object returned by the enrichment function in `expr`, in
standard format, with an additional `EMMA_record` attribute containing
the provenance information. Use
[`EMMA_get_record()`](EMMA_get_record.md) to retrieve this record

## Details

`EMMA_run()` accepts both direct calls to known enrichment functions
([`enrichGO()`](https://rdrr.io/pkg/clusterProfiler/man/enrichGO.html),
[`GSEA()`](https://rdrr.io/pkg/clusterProfiler/man/GSEA.html), `fgsea()`
...) and calls to wrapper functions that internally invoke a know
enrichment function.

## Examples

``` r
data("de_res_IFNg_vs_naive", package = "EMMA")
data("universe", package = "EMMA")
library(gprofiler2)

EMMA_run(gost(query = de_res_IFNg_vs_naive$SYMBOL, organism = "hsapiens",
correction_method = "fdr", custom_bg = universe, sources = "GO:BP"),
store_session_info = FALSE, args_form = "unevaluated")
#> ℹ Running Enrichment Analysis with  "gost" ...
#> Detected custom background input, domain scope is set to 'custom'.
#> $result
#>      query significant    p_value term_size query_size intersection_size
#> 1  query_1        TRUE 0.01074929         2          7                 2
#> 2  query_1        TRUE 0.01074929         8          7                 3
#> 3  query_1        TRUE 0.01074929         2          7                 2
#> 4  query_1        TRUE 0.01074929        52          7                 5
#> 5  query_1        TRUE 0.01074929        83          7                 6
#> 6  query_1        TRUE 0.01074929         8          7                 3
#> 7  query_1        TRUE 0.01074929         8          7                 3
#> 8  query_1        TRUE 0.01074929         2          7                 2
#> 9  query_1        TRUE 0.01101642        27          7                 4
#> 10 query_1        TRUE 0.01497153         3          7                 2
#> 11 query_1        TRUE 0.01497153        62          7                 5
#> 12 query_1        TRUE 0.01497153        60          7                 5
#> 13 query_1        TRUE 0.01497153         3          7                 2
#> 14 query_1        TRUE 0.01497153         3          7                 2
#> 15 query_1        TRUE 0.01497153        13          7                 3
#> 16 query_1        TRUE 0.01497851       170          7                 7
#> 17 query_1        TRUE 0.01544234        14          7                 3
#> 18 query_1        TRUE 0.01550713        35          7                 4
#> 19 query_1        TRUE 0.01550713       175          7                 7
#> 20 query_1        TRUE 0.01630504        15          7                 3
#> 21 query_1        TRUE 0.01745763       115          7                 6
#> 22 query_1        TRUE 0.01812935        16          7                 3
#> 23 query_1        TRUE 0.01858649        72          7                 5
#> 24 query_1        TRUE 0.01858649         4          7                 2
#> 25 query_1        TRUE 0.01882825       120          7                 6
#> 26 query_1        TRUE 0.02046523        41          7                 4
#> 27 query_1        TRUE 0.02546119         5          7                 2
#> 28 query_1        TRUE 0.02546119         5          7                 2
#> 29 query_1        TRUE 0.02546119         5          7                 2
#> 30 query_1        TRUE 0.02554065        20          7                 3
#> 31 query_1        TRUE 0.02554065        20          7                 3
#> 32 query_1        TRUE 0.03142804         6          7                 2
#> 33 query_1        TRUE 0.03142804        49          7                 4
#> 34 query_1        TRUE 0.03142804         6          7                 2
#> 35 query_1        TRUE 0.03142804         6          7                 2
#> 36 query_1        TRUE 0.03510204         1          7                 1
#> 37 query_1        TRUE 0.03510204         1          7                 1
#> 38 query_1        TRUE 0.03510204         1          7                 1
#> 39 query_1        TRUE 0.03510204         1          7                 1
#> 40 query_1        TRUE 0.03510204        63          7                 4
#> 41 query_1        TRUE 0.03510204         1          7                 1
#> 42 query_1        TRUE 0.03510204        11          7                 2
#> 43 query_1        TRUE 0.03510204         1          7                 1
#> 44 query_1        TRUE 0.03510204         1          7                 1
#> 45 query_1        TRUE 0.03510204         1          7                 1
#> 46 query_1        TRUE 0.03510204         1          7                 1
#> 47 query_1        TRUE 0.03510204         1          7                 1
#> 48 query_1        TRUE 0.03510204        39          7                 3
#> 49 query_1        TRUE 0.03510204         1          7                 1
#> 50 query_1        TRUE 0.03510204         1          7                 1
#> 51 query_1        TRUE 0.03510204         1          7                 1
#> 52 query_1        TRUE 0.03510204         1          7                 1
#> 53 query_1        TRUE 0.03510204         1          7                 1
#> 54 query_1        TRUE 0.03510204         1          7                 1
#> 55 query_1        TRUE 0.03510204        59          7                 4
#> 56 query_1        TRUE 0.03510204        63          7                 4
#> 57 query_1        TRUE 0.03510204         1          7                 1
#> 58 query_1        TRUE 0.03510204         1          7                 1
#> 59 query_1        TRUE 0.03510204         1          7                 1
#> 60 query_1        TRUE 0.03510204        10          7                 2
#> 61 query_1        TRUE 0.03510204        13          7                 2
#> 62 query_1        TRUE 0.03510204         1          7                 1
#> 63 query_1        TRUE 0.03510204         7          7                 2
#> 64 query_1        TRUE 0.03510204         1          7                 1
#> 65 query_1        TRUE 0.03510204         1          7                 1
#> 66 query_1        TRUE 0.03510204         1          7                 1
#> 67 query_1        TRUE 0.03510204         1          7                 1
#> 68 query_1        TRUE 0.03510204        12          7                 2
#> 69 query_1        TRUE 0.03510204         1          7                 1
#> 70 query_1        TRUE 0.03510204         1          7                 1
#> 71 query_1        TRUE 0.03510204         1          7                 1
#>    precision     recall    term_id source
#> 1  0.2857143 1.00000000 GO:0002062  GO:BP
#> 2  0.4285714 0.37500000 GO:0030097  GO:BP
#> 3  0.2857143 1.00000000 GO:0032330  GO:BP
#> 4  0.7142857 0.09615385 GO:0048518  GO:BP
#> 5  0.8571429 0.07228916 GO:0050896  GO:BP
#> 6  0.4285714 0.37500000 GO:0051129  GO:BP
#> 7  0.4285714 0.37500000 GO:2000026  GO:BP
#> 8  0.2857143 1.00000000 GO:0061035  GO:BP
#> 9  0.5714286 0.14814815 GO:0002376  GO:BP
#> 10 0.2857143 0.66666667 GO:0010639  GO:BP
#> 11 0.7142857 0.08064516 GO:0048519  GO:BP
#> 12 0.7142857 0.08333333 GO:0048523  GO:BP
#> 13 0.2857143 0.66666667 GO:0051216  GO:BP
#> 14 0.2857143 0.66666667 GO:0061448  GO:BP
#> 15 0.4285714 0.23076923 GO:0006952  GO:BP
#> 16 1.0000000 0.04117647 GO:0009987  GO:BP
#> 17 0.4285714 0.21428571 GO:0045595  GO:BP
#> 18 0.5714286 0.11428571 GO:0006950  GO:BP
#> 19 1.0000000 0.04000000 GO:0008150  GO:BP
#> 20 0.4285714 0.20000000 GO:0032879  GO:BP
#> 21 0.8571429 0.05217391 GO:0050789  GO:BP
#> 22 0.4285714 0.18750000 GO:0050793  GO:BP
#> 23 0.7142857 0.06944444 GO:0051716  GO:BP
#> 24 0.2857143 0.50000000 GO:0051607  GO:BP
#> 25 0.8571429 0.05000000 GO:0065007  GO:BP
#> 26 0.5714286 0.09756098 GO:0051179  GO:BP
#> 27 0.2857143 0.40000000 GO:1903706  GO:BP
#> 28 0.2857143 0.40000000 GO:0030219  GO:BP
#> 29 0.2857143 0.40000000 GO:0009615  GO:BP
#> 30 0.4285714 0.15000000 GO:0051128  GO:BP
#> 31 0.4285714 0.15000000 GO:0051239  GO:BP
#> 32 0.2857143 0.33333333 GO:0030099  GO:BP
#> 33 0.5714286 0.08163265 GO:0048522  GO:BP
#> 34 0.2857143 0.33333333 GO:0060284  GO:BP
#> 35 0.2857143 0.33333333 GO:0051050  GO:BP
#> 36 0.1428571 1.00000000 GO:0032271  GO:BP
#> 37 0.1428571 1.00000000 GO:0010720  GO:BP
#> 38 0.1428571 1.00000000 GO:0030041  GO:BP
#> 39 0.1428571 1.00000000 GO:0030071  GO:BP
#> 40 0.5714286 0.06349206 GO:0023052  GO:BP
#> 41 0.1428571 1.00000000 GO:0030833  GO:BP
#> 42 0.2857143 0.18181818 GO:0032101  GO:BP
#> 43 0.1428571 1.00000000 GO:0019835  GO:BP
#> 44 0.1428571 1.00000000 GO:0017156  GO:BP
#> 45 0.1428571 1.00000000 GO:0031577  GO:BP
#> 46 0.1428571 1.00000000 GO:0031619  GO:BP
#> 47 0.1428571 1.00000000 GO:0030101  GO:BP
#> 48 0.4285714 0.07692308 GO:0030154  GO:BP
#> 49 0.1428571 1.00000000 GO:0033045  GO:BP
#> 50 0.1428571 1.00000000 GO:0009308  GO:BP
#> 51 0.1428571 1.00000000 GO:0007091  GO:BP
#> 52 0.1428571 1.00000000 GO:0007094  GO:BP
#> 53 0.1428571 1.00000000 GO:0007259  GO:BP
#> 54 0.1428571 1.00000000 GO:0007127  GO:BP
#> 55 0.5714286 0.06779661 GO:0007165  GO:BP
#> 56 0.5714286 0.06349206 GO:0007154  GO:BP
#> 57 0.1428571 1.00000000 GO:0010965  GO:BP
#> 58 0.1428571 1.00000000 GO:0030835  GO:BP
#> 59 0.1428571 1.00000000 GO:0030837  GO:BP
#> 60 0.2857143 0.20000000 GO:0031347  GO:BP
#> 61 0.2857143 0.15384615 GO:0009607  GO:BP
#> 62 0.1428571 1.00000000 GO:0007093  GO:BP
#> 63 0.2857143 0.28571429 GO:0006954  GO:BP
#> 64 0.1428571 1.00000000 GO:0002230  GO:BP
#> 65 0.1428571 1.00000000 GO:0051125  GO:BP
#> 66 0.1428571 1.00000000 GO:0051127  GO:BP
#> 67 0.1428571 1.00000000 GO:0034341  GO:BP
#> 68 0.2857143 0.16666667 GO:0034097  GO:BP
#> 69 0.1428571 1.00000000 GO:0033048  GO:BP
#> 70 0.1428571 1.00000000 GO:0033047  GO:BP
#> 71 0.1428571 1.00000000 GO:0033316  GO:BP
#>                                                      term_name
#> 1                                  chondrocyte differentiation
#> 2                                                  hemopoiesis
#> 3                    regulation of chondrocyte differentiation
#> 4                    positive regulation of biological process
#> 5                                         response to stimulus
#> 6       negative regulation of cellular component organization
#> 7           regulation of multicellular organismal development
#> 8                          regulation of cartilage development
#> 9                                        immune system process
#> 10               negative regulation of organelle organization
#> 11                   negative regulation of biological process
#> 12                     negative regulation of cellular process
#> 13                                       cartilage development
#> 14                               connective tissue development
#> 15                                            defense response
#> 16                                            cellular process
#> 17                          regulation of cell differentiation
#> 18                                          response to stress
#> 19                                          biological_process
#> 20                                  regulation of localization
#> 21                            regulation of biological process
#> 22                         regulation of developmental process
#> 23                               cellular response to stimulus
#> 24                                   defense response to virus
#> 25                                       biological regulation
#> 26                                                localization
#> 27                                   regulation of hemopoiesis
#> 28                               megakaryocyte differentiation
#> 29                                           response to virus
#> 30               regulation of cellular component organization
#> 31              regulation of multicellular organismal process
#> 32                                myeloid cell differentiation
#> 33                     positive regulation of cellular process
#> 34                              regulation of cell development
#> 35                            positive regulation of transport
#> 36                        regulation of protein polymerization
#> 37                     positive regulation of cell development
#> 38                               actin filament polymerization
#> 39         regulation of mitotic metaphase/anaphase transition
#> 40                                                   signaling
#> 41                 regulation of actin filament polymerization
#> 42                 regulation of response to external stimulus
#> 43                                                   cytolysis
#> 44                            calcium-ion regulated exocytosis
#> 45                                spindle checkpoint signaling
#> 46    homologous chromosome orientation in meiotic metaphase I
#> 47                              natural killer cell activation
#> 48                                        cell differentiation
#> 49                  regulation of sister chromatid segregation
#> 50                                     amine metabolic process
#> 51         metaphase/anaphase transition of mitotic cell cycle
#> 52               mitotic spindle assembly checkpoint signaling
#> 53        cell surface receptor signaling pathway via JAK-STAT
#> 54                                                   meiosis I
#> 55                                         signal transduction
#> 56                                          cell communication
#> 57           regulation of mitotic sister chromatid separation
#> 58      negative regulation of actin filament depolymerization
#> 59        negative regulation of actin filament polymerization
#> 60                              regulation of defense response
#> 61                                 response to biotic stimulus
#> 62                     mitotic cell cycle checkpoint signaling
#> 63                                       inflammatory response
#> 64    positive regulation of defense response to virus by host
#> 65                              regulation of actin nucleation
#> 66                     positive regulation of actin nucleation
#> 67                              response to type II interferon
#> 68                                        response to cytokine
#> 69 negative regulation of mitotic sister chromatid segregation
#> 70          regulation of mitotic sister chromatid segregation
#> 71               meiotic spindle assembly checkpoint signaling
#>    effective_domain_size source_order      parents
#> 1                    490          634 GO:00301....
#> 2                    490         6240   GO:0048468
#> 3                    490         7003 GO:00020....
#> 4                    490        11952 GO:00081....
#> 5                    490        12476   GO:0008150
#> 6                    490        12628 GO:00160....
#> 7                    490        23538 GO:00072....
#> 8                    490        14098 GO:00512....
#> 9                    490          867   GO:0008150
#> 10                   490         4098 GO:00069....
#> 11                   490        11953 GO:00081....
#> 12                   490        11957 GO:00099....
#> 13                   490        12677 GO:00015....
#> 14                   490        14398   GO:0009888
#> 15                   490         2452   GO:0006950
#> 16                   490         3649   GO:0008150
#> 17                   490        10677 GO:00301....
#> 18                   490         2451   GO:0050896
#> 19                   490         2984             
#> 20                   490         7364 GO:00507....
#> 21                   490        12397 GO:00081....
#> 22                   490        12400 GO:00325....
#> 23                   490        12983 GO:00099....
#> 24                   490        12899 GO:00069....
#> 25                   490        14784   GO:0008150
#> 26                   490        12665   GO:0008150
#> 27                   490        21591 GO:00026....
#> 28                   490         6288   GO:0030099
#> 29                   490         3384   GO:0051707
#> 30                   490        12627 GO:00160....
#> 31                   490        12691 GO:00325....
#> 32                   490         6242 GO:00300....
#> 33                   490        11956 GO:00099....
#> 34                   490        13512 GO:00455....
#> 35                   490        12589 GO:00068....
#> 36                   490         6966 GO:00432....
#> 37                   490         4152 GO:00455....
#> 38                   490         6227 GO:00081....
#> 39                   490         6236 GO:00070....
#> 40                   490         6205   GO:0050789
#> 41                   490         6471 GO:00080....
#> 42                   490         6887 GO:00096....
#> 43                   490         5641   GO:0009987
#> 44                   490         5034   GO:0045055
#> 45                   490         6764   GO:0000075
#> 46                   490         6773 GO:00430....
#> 47                   490         6244   GO:0046649
#> 48                   490         6252   GO:0048869
#> 49                   490         7484 GO:00008....
#> 50                   490         3298   GO:0008152
#> 51                   490         2541 GO:00447....
#> 52                   490         2543 GO:00458....
#> 53                   490         2653   GO:0097696
#> 54                   490         2564 GO:00619....
#> 55                   490         2595 GO:00071....
#> 56                   490         2584   GO:0009987
#> 57                   490         4327 GO:00513....
#> 58                   490         6473 GO:00300....
#> 59                   490         6475 GO:00300....
#> 60                   490         6682 GO:00069....
#> 61                   490         3378   GO:0050896
#> 62                   490         2542 GO:00000....
#> 63                   490         2454   GO:0006952
#> 64                   490          741   GO:0050691
#> 65                   490        12624 GO:00450....
#> 66                   490        12626 GO:00450....
#> 67                   490         8006 GO:00340....
#> 68                   490         7846   GO:1901652
#> 69                   490         7487 GO:00000....
#> 70                   490         7486 GO:00000....
#> 71                   490         7599 GO:00447....
#>  [ reached 'max' / getOption("max.print") -- omitted 109 rows ]
#> 
#> $meta
#> $meta$query_metadata
#> $meta$query_metadata$queries
#> $meta$query_metadata$queries$query_1
#> [1] "IL15RA" "GBP3"   "AOC3"   "TRIM22" "MAF"    "SCIN"   "ZWINT" 
#> 
#> 
#> $meta$query_metadata$organism
#> [1] "hsapiens"
#> 
#> $meta$query_metadata$all_results
#> [1] FALSE
#> 
#> $meta$query_metadata$ordered
#> [1] FALSE
#> 
#> $meta$query_metadata$no_iea
#> [1] FALSE
#> 
#> $meta$query_metadata$sources
#> [1] "GO:BP"
#> 
#> $meta$query_metadata$combined
#> [1] FALSE
#> 
#> $meta$query_metadata$aresolve
#> named list()
#> 
#> $meta$query_metadata$numeric_ns
#> [1] "ENTREZGENE_ACC"
#> 
#> $meta$query_metadata$domain_scope
#> [1] "custom"
#> 
#> $meta$query_metadata$measure_underrepresentation
#> [1] FALSE
#> 
#> $meta$query_metadata$significance_threshold_method
#> [1] "fdr"
#> 
#> $meta$query_metadata$user_threshold
#> [1] 0.05
#> 
#> $meta$query_metadata$no_evidences
#> [1] TRUE
#> 
#> $meta$query_metadata$highlight
#> [1] FALSE
#> 
#> 
#> $meta$result_metadata
#> $meta$result_metadata$`GO:BP`
#> $meta$result_metadata$`GO:BP`$domain_size
#> [1] 20972
#> 
#> $meta$result_metadata$`GO:BP`$number_of_terms
#> [1] 24546
#> 
#> $meta$result_metadata$`GO:BP`$threshold
#> NULL
#> 
#> 
#> 
#> $meta$genes_metadata
#> $meta$genes_metadata$failed
#> list()
#> 
#> $meta$genes_metadata$ambiguous
#> named list()
#> 
#> $meta$genes_metadata$duplicates
#> list()
#> 
#> $meta$genes_metadata$query
#> $meta$genes_metadata$query$query_1
#> $meta$genes_metadata$query$query_1$mapping
#> $meta$genes_metadata$query$query_1$mapping$IL15RA
#> [1] "ENSG00000134470"
#> 
#> $meta$genes_metadata$query$query_1$mapping$GBP3
#> [1] "ENSG00000117226"
#> 
#> $meta$genes_metadata$query$query_1$mapping$AOC3
#> [1] "ENSG00000131471"
#> 
#> $meta$genes_metadata$query$query_1$mapping$TRIM22
#> [1] "ENSG00000132274"
#> 
#> $meta$genes_metadata$query$query_1$mapping$MAF
#> [1] "ENSG00000178573"
#> 
#> $meta$genes_metadata$query$query_1$mapping$SCIN
#> [1] "ENSG00000006747"
#> 
#> $meta$genes_metadata$query$query_1$mapping$ZWINT
#> [1] "ENSG00000122952"
#> 
#> 
#> $meta$genes_metadata$query$query_1$ensgs
#> [1] "ENSG00000134470" "ENSG00000117226" "ENSG00000131471" "ENSG00000132274"
#> [5] "ENSG00000178573" "ENSG00000006747" "ENSG00000122952"
#> 
#> 
#> 
#> 
#> $meta$timestamp
#> [1] "2026-05-12T11:07:34.083326+00:00"
#> 
#> $meta$version
#> [1] "e114_eg62_p19_27110d83"
#> 
#> 
#> attr(,"EMMA_record")
#> attr(,"EMMA_record")$method
#> attr(,"EMMA_record")$method$call
#> gost(query = de_res_IFNg_vs_naive$SYMBOL, organism = "hsapiens", 
#>     correction_method = "fdr", custom_bg = universe, sources = "GO:BP")
#> 
#> attr(,"EMMA_record")$method$function_name
#> [1] "gost"
#> 
#> attr(,"EMMA_record")$method$package_name
#> [1] "gprofiler2"
#> 
#> attr(,"EMMA_record")$method$package_version
#> [1] "0.2.4"
#> 
#> attr(,"EMMA_record")$method$wrapped_function
#> NULL
#> 
#> attr(,"EMMA_record")$method$wrapped_package
#> NULL
#> 
#> attr(,"EMMA_record")$method$wrapper
#> [1] FALSE
#> 
#> 
#> attr(,"EMMA_record")$input
#> attr(,"EMMA_record")$input$arguments
#> attr(,"EMMA_record")$input$arguments$query
#> de_res_IFNg_vs_naive$SYMBOL
#> 
#> attr(,"EMMA_record")$input$arguments$organism
#> [1] "hsapiens"
#> 
#> attr(,"EMMA_record")$input$arguments$correction_method
#> [1] "fdr"
#> 
#> attr(,"EMMA_record")$input$arguments$custom_bg
#> universe
#> 
#> attr(,"EMMA_record")$input$arguments$sources
#> [1] "GO:BP"
#> 
#> 
#> 
#> attr(,"EMMA_record")$annotation
#> attr(,"EMMA_record")$annotation$organism
#> [1] "hsapiens"
#> 
#> attr(,"EMMA_record")$annotation$gene_set_db
#> [1] "GO:BP"
#> 
#> attr(,"EMMA_record")$annotation$gene_set_db_version
#>                                                GO:BP 
#> "annotations: BioMart\nclasses: releases/2026-01-23" 
#> 
#> 
#> attr(,"EMMA_record")$timestamp
#> [1] "2026-05-12 13:07:33 CEST"
#> 
#> attr(,"EMMA_record")$session_info
#> NULL
#> 
#> attr(,"EMMA_record")$extra
#> list()
#> 
#> attr(,"EMMA_record")$emma_version
#> [1] "0.3.0"
#> 
```
