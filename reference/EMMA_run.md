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
(`enrichGO()`, `GSEA()`, `fgsea()` ...) and calls to wrapper functions
that internally invoke a know enrichment function.

## Examples

``` r
data("de_res_IFNg_vs_naive", package = "EMMA")
data("gene_universe", package = "EMMA")
library(gprofiler2)

EMMA_run(gost(query = de_res_IFNg_vs_naive$SYMBOL, organism = "hsapiens",
  correction_method = "fdr", custom_bg = gene_universe, sources = "GO:BP"),
  store_session_info = FALSE, args_form = "unevaluated")
#> ℹ Running Enrichment Analysis with  "gost" ...
#> Detected custom background input, domain scope is set to 'custom'.
#> $result
#>       query significant    p_value term_size query_size intersection_size
#> 1   query_1        TRUE 0.01074929         2          7                 2
#> 2   query_1        TRUE 0.01074929         8          7                 3
#> 3   query_1        TRUE 0.01074929         2          7                 2
#> 4   query_1        TRUE 0.01074929        52          7                 5
#> 5   query_1        TRUE 0.01074929        83          7                 6
#> 6   query_1        TRUE 0.01074929         8          7                 3
#> 7   query_1        TRUE 0.01074929         8          7                 3
#> 8   query_1        TRUE 0.01074929         2          7                 2
#> 9   query_1        TRUE 0.01101642        27          7                 4
#> 10  query_1        TRUE 0.01497153         3          7                 2
#> 11  query_1        TRUE 0.01497153        62          7                 5
#> 12  query_1        TRUE 0.01497153        60          7                 5
#> 13  query_1        TRUE 0.01497153         3          7                 2
#> 14  query_1        TRUE 0.01497153         3          7                 2
#> 15  query_1        TRUE 0.01497153        13          7                 3
#> 16  query_1        TRUE 0.01497851       170          7                 7
#> 17  query_1        TRUE 0.01544234        14          7                 3
#> 18  query_1        TRUE 0.01550713        35          7                 4
#> 19  query_1        TRUE 0.01550713       175          7                 7
#> 20  query_1        TRUE 0.01630504        15          7                 3
#> 21  query_1        TRUE 0.01745763       115          7                 6
#> 22  query_1        TRUE 0.01812935        16          7                 3
#> 23  query_1        TRUE 0.01858649        72          7                 5
#> 24  query_1        TRUE 0.01858649         4          7                 2
#> 25  query_1        TRUE 0.01882825       120          7                 6
#> 26  query_1        TRUE 0.02046523        41          7                 4
#> 27  query_1        TRUE 0.02546119         5          7                 2
#> 28  query_1        TRUE 0.02546119         5          7                 2
#> 29  query_1        TRUE 0.02546119         5          7                 2
#> 30  query_1        TRUE 0.02554065        20          7                 3
#> 31  query_1        TRUE 0.02554065        20          7                 3
#> 32  query_1        TRUE 0.03142804         6          7                 2
#> 33  query_1        TRUE 0.03142804        49          7                 4
#> 34  query_1        TRUE 0.03142804         6          7                 2
#> 35  query_1        TRUE 0.03142804         6          7                 2
#> 36  query_1        TRUE 0.03510204         1          7                 1
#> 37  query_1        TRUE 0.03510204         1          7                 1
#> 38  query_1        TRUE 0.03510204         1          7                 1
#> 39  query_1        TRUE 0.03510204         1          7                 1
#> 40  query_1        TRUE 0.03510204        63          7                 4
#> 41  query_1        TRUE 0.03510204         1          7                 1
#> 42  query_1        TRUE 0.03510204        11          7                 2
#> 43  query_1        TRUE 0.03510204         1          7                 1
#> 44  query_1        TRUE 0.03510204         1          7                 1
#> 45  query_1        TRUE 0.03510204         1          7                 1
#> 46  query_1        TRUE 0.03510204         1          7                 1
#> 47  query_1        TRUE 0.03510204         1          7                 1
#> 48  query_1        TRUE 0.03510204        39          7                 3
#> 49  query_1        TRUE 0.03510204         1          7                 1
#> 50  query_1        TRUE 0.03510204         1          7                 1
#> 51  query_1        TRUE 0.03510204         1          7                 1
#> 52  query_1        TRUE 0.03510204         1          7                 1
#> 53  query_1        TRUE 0.03510204         1          7                 1
#> 54  query_1        TRUE 0.03510204         1          7                 1
#> 55  query_1        TRUE 0.03510204        59          7                 4
#> 56  query_1        TRUE 0.03510204        63          7                 4
#> 57  query_1        TRUE 0.03510204         1          7                 1
#> 58  query_1        TRUE 0.03510204         1          7                 1
#> 59  query_1        TRUE 0.03510204         1          7                 1
#> 60  query_1        TRUE 0.03510204        10          7                 2
#> 61  query_1        TRUE 0.03510204        13          7                 2
#> 62  query_1        TRUE 0.03510204         1          7                 1
#> 63  query_1        TRUE 0.03510204         7          7                 2
#> 64  query_1        TRUE 0.03510204         1          7                 1
#> 65  query_1        TRUE 0.03510204         1          7                 1
#> 66  query_1        TRUE 0.03510204         1          7                 1
#> 67  query_1        TRUE 0.03510204         1          7                 1
#> 68  query_1        TRUE 0.03510204        12          7                 2
#> 69  query_1        TRUE 0.03510204         1          7                 1
#> 70  query_1        TRUE 0.03510204         1          7                 1
#> 71  query_1        TRUE 0.03510204         1          7                 1
#> 72  query_1        TRUE 0.03510204         1          7                 1
#> 73  query_1        TRUE 0.03510204         7          7                 2
#> 74  query_1        TRUE 0.03510204         1          7                 1
#> 75  query_1        TRUE 0.03510204         1          7                 1
#> 76  query_1        TRUE 0.03510204         1          7                 1
#> 77  query_1        TRUE 0.03510204         1          7                 1
#> 78  query_1        TRUE 0.03510204         1          7                 1
#> 79  query_1        TRUE 0.03510204         1          7                 1
#> 80  query_1        TRUE 0.03510204        28          7                 3
#> 81  query_1        TRUE 0.03510204        24          7                 3
#> 82  query_1        TRUE 0.03510204         7          7                 2
#> 83  query_1        TRUE 0.03510204         1          7                 1
#> 84  query_1        TRUE 0.03510204         1          7                 1
#> 85  query_1        TRUE 0.03510204         1          7                 1
#> 86  query_1        TRUE 0.03510204         1          7                 1
#> 87  query_1        TRUE 0.03510204         1          7                 1
#> 88  query_1        TRUE 0.03510204         1          7                 1
#> 89  query_1        TRUE 0.03510204        10          7                 2
#> 90  query_1        TRUE 0.03510204         1          7                 1
#> 91  query_1        TRUE 0.03510204         1          7                 1
#> 92  query_1        TRUE 0.03510204         1          7                 1
#> 93  query_1        TRUE 0.03510204         1          7                 1
#> 94  query_1        TRUE 0.03510204         1          7                 1
#> 95  query_1        TRUE 0.03510204         1          7                 1
#> 96  query_1        TRUE 0.03510204        13          7                 2
#> 97  query_1        TRUE 0.03510204         1          7                 1
#> 98  query_1        TRUE 0.03510204         1          7                 1
#> 99  query_1        TRUE 0.03510204        32          7                 3
#> 100 query_1        TRUE 0.03510204         1          7                 1
#> 101 query_1        TRUE 0.03510204         1          7                 1
#> 102 query_1        TRUE 0.03510204         1          7                 1
#> 103 query_1        TRUE 0.03510204         1          7                 1
#> 104 query_1        TRUE 0.03510204        39          7                 3
#> 105 query_1        TRUE 0.03510204         1          7                 1
#> 106 query_1        TRUE 0.03510204         1          7                 1
#> 107 query_1        TRUE 0.03510204         1          7                 1
#> 108 query_1        TRUE 0.03510204         1          7                 1
#> 109 query_1        TRUE 0.03510204         1          7                 1
#> 110 query_1        TRUE 0.03510204       111          7                 5
#> 111 query_1        TRUE 0.03510204         1          7                 1
#> 112 query_1        TRUE 0.03510204        39          7                 3
#> 113 query_1        TRUE 0.03510204         1          7                 1
#> 114 query_1        TRUE 0.03510204         1          7                 1
#> 115 query_1        TRUE 0.03510204        10          7                 2
#> 116 query_1        TRUE 0.03510204         7          7                 2
#> 117 query_1        TRUE 0.03510204        30          7                 3
#> 118 query_1        TRUE 0.03510204         1          7                 1
#> 119 query_1        TRUE 0.03510204         1          7                 1
#> 120 query_1        TRUE 0.03510204         9          7                 2
#> 121 query_1        TRUE 0.03510204        13          7                 2
#> 122 query_1        TRUE 0.03510204        12          7                 2
#> 123 query_1        TRUE 0.03510204        40          7                 3
#> 124 query_1        TRUE 0.03510204         1          7                 1
#> 125 query_1        TRUE 0.03510204         1          7                 1
#> 126 query_1        TRUE 0.03510204         1          7                 1
#> 127 query_1        TRUE 0.03510204         7          7                 2
#> 128 query_1        TRUE 0.03510204         1          7                 1
#> 129 query_1        TRUE 0.03510204         1          7                 1
#> 130 query_1        TRUE 0.03510204         1          7                 1
#> 131 query_1        TRUE 0.03510204         1          7                 1
#> 132 query_1        TRUE 0.03510204         1          7                 1
#> 133 query_1        TRUE 0.03510204         1          7                 1
#> 134 query_1        TRUE 0.03510204         1          7                 1
#> 135 query_1        TRUE 0.03510204         1          7                 1
#> 136 query_1        TRUE 0.03510204         1          7                 1
#> 137 query_1        TRUE 0.03510204         1          7                 1
#> 138 query_1        TRUE 0.03510204         1          7                 1
#> 139 query_1        TRUE 0.03510204         1          7                 1
#> 140 query_1        TRUE 0.03510204         1          7                 1
#> 141 query_1        TRUE 0.03510204         1          7                 1
#> 142 query_1        TRUE 0.03510204         1          7                 1
#> 143 query_1        TRUE 0.03510204         1          7                 1
#> 144 query_1        TRUE 0.03510204         1          7                 1
#> 145 query_1        TRUE 0.03510204        11          7                 2
#> 146 query_1        TRUE 0.03510204         1          7                 1
#> 147 query_1        TRUE 0.03510204         1          7                 1
#> 148 query_1        TRUE 0.03510204         1          7                 1
#> 149 query_1        TRUE 0.03510204         1          7                 1
#> 150 query_1        TRUE 0.03510204        11          7                 2
#> 151 query_1        TRUE 0.03510204         1          7                 1
#> 152 query_1        TRUE 0.03510204        10          7                 2
#> 153 query_1        TRUE 0.03510204         1          7                 1
#> 154 query_1        TRUE 0.03510204         1          7                 1
#> 155 query_1        TRUE 0.03510204        12          7                 2
#> 156 query_1        TRUE 0.03510204         1          7                 1
#> 157 query_1        TRUE 0.03510204         1          7                 1
#> 158 query_1        TRUE 0.03510204         1          7                 1
#> 159 query_1        TRUE 0.03510204         1          7                 1
#> 160 query_1        TRUE 0.03510204         1          7                 1
#> 161 query_1        TRUE 0.03510204         1          7                 1
#> 162 query_1        TRUE 0.03510204         1          7                 1
#> 163 query_1        TRUE 0.03510204         1          7                 1
#> 164 query_1        TRUE 0.03510204         1          7                 1
#> 165 query_1        TRUE 0.03510204         1          7                 1
#> 166 query_1        TRUE 0.03510204         1          7                 1
#> 167 query_1        TRUE 0.03510204         1          7                 1
#> 168 query_1        TRUE 0.03510204         1          7                 1
#> 169 query_1        TRUE 0.03510204         1          7                 1
#> 170 query_1        TRUE 0.03510204         1          7                 1
#> 171 query_1        TRUE 0.03510204         1          7                 1
#> 172 query_1        TRUE 0.03510204         1          7                 1
#> 173 query_1        TRUE 0.03510204         1          7                 1
#> 174 query_1        TRUE 0.03510204         1          7                 1
#> 175 query_1        TRUE 0.03510204         1          7                 1
#> 176 query_1        TRUE 0.03588311        14          7                 2
#> 177 query_1        TRUE 0.04088623        15          7                 2
#> 178 query_1        TRUE 0.04588672        16          7                 2
#> 179 query_1        TRUE 0.04588672        16          7                 2
#> 180 query_1        TRUE 0.04958233        46          7                 3
#>     precision     recall    term_id source
#> 1   0.2857143 1.00000000 GO:0002062  GO:BP
#> 2   0.4285714 0.37500000 GO:0030097  GO:BP
#> 3   0.2857143 1.00000000 GO:0032330  GO:BP
#> 4   0.7142857 0.09615385 GO:0048518  GO:BP
#> 5   0.8571429 0.07228916 GO:0050896  GO:BP
#> 6   0.4285714 0.37500000 GO:0051129  GO:BP
#> 7   0.4285714 0.37500000 GO:2000026  GO:BP
#> 8   0.2857143 1.00000000 GO:0061035  GO:BP
#> 9   0.5714286 0.14814815 GO:0002376  GO:BP
#> 10  0.2857143 0.66666667 GO:0010639  GO:BP
#> 11  0.7142857 0.08064516 GO:0048519  GO:BP
#> 12  0.7142857 0.08333333 GO:0048523  GO:BP
#> 13  0.2857143 0.66666667 GO:0051216  GO:BP
#> 14  0.2857143 0.66666667 GO:0061448  GO:BP
#> 15  0.4285714 0.23076923 GO:0006952  GO:BP
#> 16  1.0000000 0.04117647 GO:0009987  GO:BP
#> 17  0.4285714 0.21428571 GO:0045595  GO:BP
#> 18  0.5714286 0.11428571 GO:0006950  GO:BP
#> 19  1.0000000 0.04000000 GO:0008150  GO:BP
#> 20  0.4285714 0.20000000 GO:0032879  GO:BP
#> 21  0.8571429 0.05217391 GO:0050789  GO:BP
#> 22  0.4285714 0.18750000 GO:0050793  GO:BP
#> 23  0.7142857 0.06944444 GO:0051716  GO:BP
#> 24  0.2857143 0.50000000 GO:0051607  GO:BP
#> 25  0.8571429 0.05000000 GO:0065007  GO:BP
#> 26  0.5714286 0.09756098 GO:0051179  GO:BP
#> 27  0.2857143 0.40000000 GO:1903706  GO:BP
#> 28  0.2857143 0.40000000 GO:0030219  GO:BP
#> 29  0.2857143 0.40000000 GO:0009615  GO:BP
#> 30  0.4285714 0.15000000 GO:0051128  GO:BP
#> 31  0.4285714 0.15000000 GO:0051239  GO:BP
#> 32  0.2857143 0.33333333 GO:0030099  GO:BP
#> 33  0.5714286 0.08163265 GO:0048522  GO:BP
#> 34  0.2857143 0.33333333 GO:0060284  GO:BP
#> 35  0.2857143 0.33333333 GO:0051050  GO:BP
#> 36  0.1428571 1.00000000 GO:0032271  GO:BP
#> 37  0.1428571 1.00000000 GO:0010720  GO:BP
#> 38  0.1428571 1.00000000 GO:0030041  GO:BP
#> 39  0.1428571 1.00000000 GO:0030071  GO:BP
#> 40  0.5714286 0.06349206 GO:0023052  GO:BP
#> 41  0.1428571 1.00000000 GO:0030833  GO:BP
#> 42  0.2857143 0.18181818 GO:0032101  GO:BP
#> 43  0.1428571 1.00000000 GO:0019835  GO:BP
#> 44  0.1428571 1.00000000 GO:0017156  GO:BP
#> 45  0.1428571 1.00000000 GO:0031577  GO:BP
#> 46  0.1428571 1.00000000 GO:0031619  GO:BP
#> 47  0.1428571 1.00000000 GO:0030101  GO:BP
#> 48  0.4285714 0.07692308 GO:0030154  GO:BP
#> 49  0.1428571 1.00000000 GO:0033045  GO:BP
#> 50  0.1428571 1.00000000 GO:0009308  GO:BP
#> 51  0.1428571 1.00000000 GO:0007091  GO:BP
#> 52  0.1428571 1.00000000 GO:0007094  GO:BP
#> 53  0.1428571 1.00000000 GO:0007259  GO:BP
#> 54  0.1428571 1.00000000 GO:0007127  GO:BP
#> 55  0.5714286 0.06779661 GO:0007165  GO:BP
#> 56  0.5714286 0.06349206 GO:0007154  GO:BP
#> 57  0.1428571 1.00000000 GO:0010965  GO:BP
#> 58  0.1428571 1.00000000 GO:0030835  GO:BP
#> 59  0.1428571 1.00000000 GO:0030837  GO:BP
#> 60  0.2857143 0.20000000 GO:0031347  GO:BP
#> 61  0.2857143 0.15384615 GO:0009607  GO:BP
#> 62  0.1428571 1.00000000 GO:0007093  GO:BP
#> 63  0.2857143 0.28571429 GO:0006954  GO:BP
#> 64  0.1428571 1.00000000 GO:0002230  GO:BP
#> 65  0.1428571 1.00000000 GO:0051125  GO:BP
#> 66  0.1428571 1.00000000 GO:0051127  GO:BP
#> 67  0.1428571 1.00000000 GO:0034341  GO:BP
#> 68  0.2857143 0.16666667 GO:0034097  GO:BP
#> 69  0.1428571 1.00000000 GO:0033048  GO:BP
#> 70  0.1428571 1.00000000 GO:0033047  GO:BP
#> 71  0.1428571 1.00000000 GO:0033316  GO:BP
#> 72  0.1428571 1.00000000 GO:0033313  GO:BP
#> 73  0.2857143 0.28571429 GO:0033043  GO:BP
#> 74  0.1428571 1.00000000 GO:0032825  GO:BP
#> 75  0.1428571 1.00000000 GO:0032823  GO:BP
#> 76  0.1428571 1.00000000 GO:0032816  GO:BP
#> 77  0.1428571 1.00000000 GO:0032272  GO:BP
#> 78  0.1428571 1.00000000 GO:0032814  GO:BP
#> 79  0.1428571 1.00000000 GO:0033046  GO:BP
#> 80  0.4285714 0.10714286 GO:0035556  GO:BP
#> 81  0.4285714 0.12500000 GO:0048468  GO:BP
#> 82  0.2857143 0.28571429 GO:0045597  GO:BP
#> 83  0.1428571 1.00000000 GO:0045132  GO:BP
#> 84  0.1428571 1.00000000 GO:0045143  GO:BP
#> 85  0.1428571 1.00000000 GO:0045619  GO:BP
#> 86  0.1428571 1.00000000 GO:0045621  GO:BP
#> 87  0.1428571 1.00000000 GO:0043060  GO:BP
#> 88  0.1428571 1.00000000 GO:0035723  GO:BP
#> 89  0.2857143 0.20000000 GO:0045087  GO:BP
#> 90  0.1428571 1.00000000 GO:0044784  GO:BP
#> 91  0.1428571 1.00000000 GO:0045010  GO:BP
#> 92  0.1428571 1.00000000 GO:0044785  GO:BP
#> 93  0.1428571 1.00000000 GO:0043242  GO:BP
#> 94  0.1428571 1.00000000 GO:0044771  GO:BP
#> 95  0.1428571 1.00000000 GO:0044779  GO:BP
#> 96  0.2857143 0.15384615 GO:0043207  GO:BP
#> 97  0.1428571 1.00000000 GO:0051307  GO:BP
#> 98  0.1428571 1.00000000 GO:0051310  GO:BP
#> 99  0.4285714 0.09375000 GO:0048731  GO:BP
#> 100 0.1428571 1.00000000 GO:0048839  GO:BP
#> 101 0.1428571 1.00000000 GO:0045835  GO:BP
#> 102 0.1428571 1.00000000 GO:0045839  GO:BP
#> 103 0.1428571 1.00000000 GO:0045841  GO:BP
#> 104 0.4285714 0.07692308 GO:0048583  GO:BP
#> 105 0.1428571 1.00000000 GO:0045654  GO:BP
#> 106 0.1428571 1.00000000 GO:0045639  GO:BP
#> 107 0.1428571 1.00000000 GO:0050688  GO:BP
#> 108 0.1428571 1.00000000 GO:0051016  GO:BP
#> 109 0.1428571 1.00000000 GO:0051014  GO:BP
#> 110 0.7142857 0.04504505 GO:0050794  GO:BP
#> 111 0.1428571 1.00000000 GO:0050691  GO:BP
#> 112 0.4285714 0.07692308 GO:0048869  GO:BP
#> 113 0.1428571 1.00000000 GO:0051494  GO:BP
#> 114 0.1428571 1.00000000 GO:0051693  GO:BP
#> 115 0.2857143 0.20000000 GO:0051049  GO:BP
#> 116 0.2857143 0.28571429 GO:0051094  GO:BP
#> 117 0.4285714 0.10000000 GO:0051234  GO:BP
#> 118 0.1428571 1.00000000 GO:0051304  GO:BP
#> 119 0.1428571 1.00000000 GO:0051306  GO:BP
#> 120 0.2857143 0.22222222 GO:0051130  GO:BP
#> 121 0.2857143 0.15384615 GO:0051707  GO:BP
#> 122 0.2857143 0.16666667 GO:0016192  GO:BP
#> 123 0.4285714 0.07500000 GO:0007275  GO:BP
#> 124 0.1428571 1.00000000 GO:0007088  GO:BP
#> 125 0.1428571 1.00000000 GO:0001779  GO:BP
#> 126 0.1428571 1.00000000 GO:0002088  GO:BP
#> 127 0.2857143 0.28571429 GO:0001501  GO:BP
#> 128 0.1428571 1.00000000 GO:0000209  GO:BP
#> 129 0.1428571 1.00000000 GO:1905819  GO:BP
#> 130 0.1428571 1.00000000 GO:1901993  GO:BP
#> 131 0.1428571 1.00000000 GO:1902100  GO:BP
#> 132 0.1428571 1.00000000 GO:1901994  GO:BP
#> 133 0.1428571 1.00000000 GO:0051311  GO:BP
#> 134 0.1428571 1.00000000 GO:0051447  GO:BP
#> 135 0.1428571 1.00000000 GO:0051715  GO:BP
#> 136 0.1428571 1.00000000 GO:0051985  GO:BP
#> 137 0.1428571 1.00000000 GO:0060631  GO:BP
#> 138 0.1428571 1.00000000 GO:0061982  GO:BP
#> 139 0.1428571 1.00000000 GO:0070269  GO:BP
#> 140 0.1428571 1.00000000 GO:0070306  GO:BP
#> 141 0.1428571 1.00000000 GO:0070534  GO:BP
#> 142 0.1428571 1.00000000 GO:0070672  GO:BP
#> 143 0.1428571 1.00000000 GO:0051784  GO:BP
#> 144 0.1428571 1.00000000 GO:0051983  GO:BP
#> 145 0.2857143 0.18181818 GO:0071345  GO:BP
#> 146 0.1428571 1.00000000 GO:0071346  GO:BP
#> 147 0.1428571 1.00000000 GO:0071350  GO:BP
#> 148 0.1428571 1.00000000 GO:0090231  GO:BP
#> 149 0.1428571 1.00000000 GO:0110029  GO:BP
#> 150 0.2857143 0.18181818 GO:0098542  GO:BP
#> 151 0.1428571 1.00000000 GO:0140467  GO:BP
#> 152 0.2857143 0.20000000 GO:0140546  GO:BP
#> 153 0.1428571 1.00000000 GO:1901976  GO:BP
#> 154 0.1428571 1.00000000 GO:0140639  GO:BP
#> 155 0.2857143 0.16666667 GO:1901652  GO:BP
#> 156 0.1428571 1.00000000 GO:1901880  GO:BP
#> 157 0.1428571 1.00000000 GO:1901991  GO:BP
#> 158 0.1428571 1.00000000 GO:1901990  GO:BP
#> 159 0.1428571 1.00000000 GO:0071173  GO:BP
#> 160 0.1428571 1.00000000 GO:0071174  GO:BP
#> 161 0.1428571 1.00000000 GO:2000816  GO:BP
#> 162 0.1428571 1.00000000 GO:2000242  GO:BP
#> 163 0.1428571 1.00000000 GO:2001251  GO:BP
#> 164 0.1428571 1.00000000 GO:1905133  GO:BP
#> 165 0.1428571 1.00000000 GO:1902103  GO:BP
#> 166 0.1428571 1.00000000 GO:1902105  GO:BP
#> 167 0.1428571 1.00000000 GO:1902107  GO:BP
#> 168 0.1428571 1.00000000 GO:1902099  GO:BP
#> 169 0.1428571 1.00000000 GO:1902904  GO:BP
#> 170 0.1428571 1.00000000 GO:1903708  GO:BP
#> 171 0.1428571 1.00000000 GO:1905132  GO:BP
#> 172 0.1428571 1.00000000 GO:1902102  GO:BP
#> 173 0.1428571 1.00000000 GO:1905318  GO:BP
#> 174 0.1428571 1.00000000 GO:1905325  GO:BP
#> 175 0.1428571 1.00000000 GO:1905818  GO:BP
#> 176 0.2857143 0.14285714 GO:0044419  GO:BP
#> 177 0.2857143 0.13333333 GO:0080134  GO:BP
#> 178 0.2857143 0.12500000 GO:0002682  GO:BP
#> 179 0.2857143 0.12500000 GO:0006955  GO:BP
#> 180 0.4285714 0.06521739 GO:0048856  GO:BP
#>                                                                      term_name
#> 1                                                  chondrocyte differentiation
#> 2                                                                  hemopoiesis
#> 3                                    regulation of chondrocyte differentiation
#> 4                                    positive regulation of biological process
#> 5                                                         response to stimulus
#> 6                       negative regulation of cellular component organization
#> 7                           regulation of multicellular organismal development
#> 8                                          regulation of cartilage development
#> 9                                                        immune system process
#> 10                               negative regulation of organelle organization
#> 11                                   negative regulation of biological process
#> 12                                     negative regulation of cellular process
#> 13                                                       cartilage development
#> 14                                               connective tissue development
#> 15                                                            defense response
#> 16                                                            cellular process
#> 17                                          regulation of cell differentiation
#> 18                                                          response to stress
#> 19                                                          biological_process
#> 20                                                  regulation of localization
#> 21                                            regulation of biological process
#> 22                                         regulation of developmental process
#> 23                                               cellular response to stimulus
#> 24                                                   defense response to virus
#> 25                                                       biological regulation
#> 26                                                                localization
#> 27                                                   regulation of hemopoiesis
#> 28                                               megakaryocyte differentiation
#> 29                                                           response to virus
#> 30                               regulation of cellular component organization
#> 31                              regulation of multicellular organismal process
#> 32                                                myeloid cell differentiation
#> 33                                     positive regulation of cellular process
#> 34                                              regulation of cell development
#> 35                                            positive regulation of transport
#> 36                                        regulation of protein polymerization
#> 37                                     positive regulation of cell development
#> 38                                               actin filament polymerization
#> 39                         regulation of mitotic metaphase/anaphase transition
#> 40                                                                   signaling
#> 41                                 regulation of actin filament polymerization
#> 42                                 regulation of response to external stimulus
#> 43                                                                   cytolysis
#> 44                                            calcium-ion regulated exocytosis
#> 45                                                spindle checkpoint signaling
#> 46                    homologous chromosome orientation in meiotic metaphase I
#> 47                                              natural killer cell activation
#> 48                                                        cell differentiation
#> 49                                  regulation of sister chromatid segregation
#> 50                                                     amine metabolic process
#> 51                         metaphase/anaphase transition of mitotic cell cycle
#> 52                               mitotic spindle assembly checkpoint signaling
#> 53                        cell surface receptor signaling pathway via JAK-STAT
#> 54                                                                   meiosis I
#> 55                                                         signal transduction
#> 56                                                          cell communication
#> 57                           regulation of mitotic sister chromatid separation
#> 58                      negative regulation of actin filament depolymerization
#> 59                        negative regulation of actin filament polymerization
#> 60                                              regulation of defense response
#> 61                                                 response to biotic stimulus
#> 62                                     mitotic cell cycle checkpoint signaling
#> 63                                                       inflammatory response
#> 64                    positive regulation of defense response to virus by host
#> 65                                              regulation of actin nucleation
#> 66                                     positive regulation of actin nucleation
#> 67                                              response to type II interferon
#> 68                                                        response to cytokine
#> 69                 negative regulation of mitotic sister chromatid segregation
#> 70                          regulation of mitotic sister chromatid segregation
#> 71                               meiotic spindle assembly checkpoint signaling
#> 72                                     meiotic cell cycle checkpoint signaling
#> 73                                        regulation of organelle organization
#> 74                  positive regulation of natural killer cell differentiation
#> 75                           regulation of natural killer cell differentiation
#> 76                       positive regulation of natural killer cell activation
#> 77                               negative regulation of protein polymerization
#> 78                                regulation of natural killer cell activation
#> 79                         negative regulation of sister chromatid segregation
#> 80                                           intracellular signal transduction
#> 81                                                            cell development
#> 82                                 positive regulation of cell differentiation
#> 83                                              meiotic chromosome segregation
#> 84                                           homologous chromosome segregation
#> 85                                    regulation of lymphocyte differentiation
#> 86                           positive regulation of lymphocyte differentiation
#> 87                         meiotic metaphase I homologous chromosome alignment
#> 88                                   interleukin-15-mediated signaling pathway
#> 89                                                      innate immune response
#> 90                                 metaphase/anaphase transition of cell cycle
#> 91                                                            actin nucleation
#> 92                         metaphase/anaphase transition of meiotic cell cycle
#> 93               negative regulation of protein-containing complex disassembly
#> 94                                         meiotic cell cycle phase transition
#> 95                                        meiotic spindle checkpoint signaling
#> 96                                        response to external biotic stimulus
#> 97                                               meiotic chromosome separation
#> 98                                              metaphase chromosome alignment
#> 99                                                          system development
#> 100                                                      inner ear development
#> 101                            negative regulation of meiotic nuclear division
#> 102                            negative regulation of mitotic nuclear division
#> 103               negative regulation of mitotic metaphase/anaphase transition
#> 104                                         regulation of response to stimulus
#> 105                       positive regulation of megakaryocyte differentiation
#> 106                        positive regulation of myeloid cell differentiation
#> 107                                    regulation of defense response to virus
#> 108                                          barbed-end actin filament capping
#> 109                                                    actin filament severing
#> 110                                             regulation of cellular process
#> 111                            regulation of defense response to virus by host
#> 112                                             cellular developmental process
#> 113                           negative regulation of cytoskeleton organization
#> 114                                                     actin filament capping
#> 115                                                    regulation of transport
#> 116                               positive regulation of developmental process
#> 117                                              establishment of localization
#> 118                                                      chromosome separation
#> 119                                        mitotic sister chromatid separation
#> 120                     positive regulation of cellular component organization
#> 121                                                 response to other organism
#> 122                                                 vesicle-mediated transport
#> 123                                         multicellular organism development
#> 124                                     regulation of mitotic nuclear division
#> 125                                        natural killer cell differentiation
#> 126                                        lens development in camera-type eye
#> 127                                                skeletal system development
#> 128                                                 protein polyubiquitination
#> 129                               negative regulation of chromosome separation
#> 130                          regulation of meiotic cell cycle phase transition
#> 131         negative regulation of metaphase/anaphase transition of cell cycle
#> 132                 negative regulation of meiotic cell cycle phase transition
#> 133                                     meiotic metaphase chromosome alignment
#> 134                                  negative regulation of meiotic cell cycle
#> 135                                              cytolysis in another organism
#> 136                              negative regulation of chromosome segregation
#> 137                                                    regulation of meiosis I
#> 138                                               meiosis I cell cycle process
#> 139                                           pyroptotic inflammatory response
#> 140                                            lens fiber cell differentiation
#> 141                                          protein K63-linked ubiquitination
#> 142                                                 response to interleukin-15
#> 143                                    negative regulation of nuclear division
#> 144                                       regulation of chromosome segregation
#> 145                                     cellular response to cytokine stimulus
#> 146                                    cellular response to type II interferon
#> 147                                        cellular response to interleukin-15
#> 148                                           regulation of spindle checkpoint
#> 149                                           negative regulation of meiosis I
#> 150                                         defense response to other organism
#> 151                                       integrated stress response signaling
#> 152                                               defense response to symbiont
#> 153                                        regulation of cell cycle checkpoint
#> 154                    positive regulation of pyroptotic inflammatory response
#> 155                                                        response to peptide
#> 156                            negative regulation of protein depolymerization
#> 157                 negative regulation of mitotic cell cycle phase transition
#> 158                          regulation of mitotic cell cycle phase transition
#> 159                                      spindle assembly checkpoint signaling
#> 160                                       mitotic spindle checkpoint signaling
#> 161                 negative regulation of mitotic sister chromatid separation
#> 162                                negative regulation of reproductive process
#> 163                             negative regulation of chromosome organization
#> 164                       negative regulation of meiotic chromosome separation
#> 165 negative regulation of metaphase/anaphase transition of meiotic cell cycle
#> 166                                    regulation of leukocyte differentiation
#> 167                           positive regulation of leukocyte differentiation
#> 168                  regulation of metaphase/anaphase transition of cell cycle
#> 169                   negative regulation of supramolecular fiber organization
#> 170                                         positive regulation of hemopoiesis
#> 171                                regulation of meiotic chromosome separation
#> 172          regulation of metaphase/anaphase transition of meiotic cell cycle
#> 173                            meiosis I spindle assembly checkpoint signaling
#> 174                        regulation of meiosis I spindle assembly checkpoint
#> 175                                        regulation of chromosome separation
#> 176  biological process involved in interspecies interaction between organisms
#> 177                                           regulation of response to stress
#> 178                                        regulation of immune system process
#> 179                                                            immune response
#> 180                                           anatomical structure development
#>     effective_domain_size source_order      parents
#> 1                     490          634 GO:00301....
#> 2                     490         6240   GO:0048468
#> 3                     490         7003 GO:00020....
#> 4                     490        11952 GO:00081....
#> 5                     490        12476   GO:0008150
#> 6                     490        12628 GO:00160....
#> 7                     490        23538 GO:00072....
#> 8                     490        14098 GO:00512....
#> 9                     490          867   GO:0008150
#> 10                    490         4098 GO:00069....
#> 11                    490        11953 GO:00081....
#> 12                    490        11957 GO:00099....
#> 13                    490        12677 GO:00015....
#> 14                    490        14398   GO:0009888
#> 15                    490         2452   GO:0006950
#> 16                    490         3649   GO:0008150
#> 17                    490        10677 GO:00301....
#> 18                    490         2451   GO:0050896
#> 19                    490         2984             
#> 20                    490         7364 GO:00507....
#> 21                    490        12397 GO:00081....
#> 22                    490        12400 GO:00325....
#> 23                    490        12983 GO:00099....
#> 24                    490        12899 GO:00069....
#> 25                    490        14784   GO:0008150
#> 26                    490        12665   GO:0008150
#> 27                    490        21591 GO:00026....
#> 28                    490         6288   GO:0030099
#> 29                    490         3384   GO:0051707
#> 30                    490        12627 GO:00160....
#> 31                    490        12691 GO:00325....
#> 32                    490         6242 GO:00300....
#> 33                    490        11956 GO:00099....
#> 34                    490        13512 GO:00455....
#> 35                    490        12589 GO:00068....
#> 36                    490         6966 GO:00432....
#> 37                    490         4152 GO:00455....
#> 38                    490         6227 GO:00081....
#> 39                    490         6236 GO:00070....
#> 40                    490         6205   GO:0050789
#> 41                    490         6471 GO:00080....
#> 42                    490         6887 GO:00096....
#> 43                    490         5641   GO:0009987
#> 44                    490         5034   GO:0045055
#> 45                    490         6764   GO:0000075
#> 46                    490         6773 GO:00430....
#> 47                    490         6244   GO:0046649
#> 48                    490         6252   GO:0048869
#> 49                    490         7484 GO:00008....
#> 50                    490         3298   GO:0008152
#> 51                    490         2541 GO:00447....
#> 52                    490         2543 GO:00458....
#> 53                    490         2653   GO:0097696
#> 54                    490         2564 GO:00619....
#> 55                    490         2595 GO:00071....
#> 56                    490         2584   GO:0009987
#> 57                    490         4327 GO:00513....
#> 58                    490         6473 GO:00300....
#> 59                    490         6475 GO:00300....
#> 60                    490         6682 GO:00069....
#> 61                    490         3378   GO:0050896
#> 62                    490         2542 GO:00000....
#> 63                    490         2454   GO:0006952
#> 64                    490          741   GO:0050691
#> 65                    490        12624 GO:00450....
#> 66                    490        12626 GO:00450....
#> 67                    490         8006 GO:00340....
#> 68                    490         7846   GO:1901652
#> 69                    490         7487 GO:00000....
#> 70                    490         7486 GO:00000....
#> 71                    490         7599 GO:00447....
#> 72                    490         7596 GO:00000....
#> 73                    490         7482 GO:00069....
#> 74                    490         7343 GO:00017....
#> 75                    490         7341 GO:00017....
#> 76                    490         7337 GO:00301....
#> 77                    490         6967 GO:00313....
#> 78                    490         7335 GO:00301....
#> 79                    490         7485 GO:00008....
#> 80                    490         8505   GO:0007165
#> 81                    490        11920 GO:00301....
#> 82                    490        10679 GO:00301....
#> 83                    490        10533 GO:00988....
#> 84                    490        10538 GO:00071....
#> 85                    490        10701 GO:00300....
#> 86                    490        10703 GO:00300....
#> 87                    490         9844 GO:00451....
#> 88                    490         8603 GO:00192....
#> 89                    490        10511 GO:00069....
#> 90                    490        10405 GO:00330....
#> 91                    490        10468   GO:0007015
#> 92                    490        10406 GO:00447....
#> 93                    490         9912 GO:00329....
#> 94                    490        10396 GO:00447....
#> 95                    490        10401 GO:00315....
#> 96                    490         9908 GO:00096....
#> 97                    490        12736 GO:00451....
#> 98                    490        12739 GO:00500....
#> 99                    490        12138 GO:00072....
#> 100                   490        12230 GO:00435....
#> 101                   490        10878 GO:00109....
#> 102                   490        10882 GO:00070....
#> 103                   490        10884 GO:00070....
#> 104                   490        12005 GO:00507....
#> 105                   490        10736 GO:00302....
#> 106                   490        10721 GO:00300....
#> 107                   490        12360 GO:00028....
#> 108                   490        12570   GO:0051693
#> 109                   490        12569   GO:0030029
#> 110                   490        12401 GO:00099....
#> 111                   490        12362   GO:0050688
#> 112                   490        12259 GO:00099....
#> 113                   490        12836 GO:00070....
#> 114                   490        12970 GO:00308....
#> 115                   490        12588 GO:00068....
#> 116                   490        12612 GO:00325....
#> 117                   490        12687   GO:0051179
#> 118                   490        12733 GO:00070....
#> 119                   490        12735 GO:00000....
#> 120                   490        12629 GO:00160....
#> 121                   490        12978 GO:00432....
#> 122                   490         4920 GO:00068....
#> 123                   490         2666 GO:00325....
#> 124                   490         2539 GO:00073....
#> 125                   490          431 GO:00300....
#> 126                   490          655 GO:00430....
#> 127                   490          306   GO:0048731
#> 128                   490           58   GO:0016567
#> 129                   490        23105 GO:00513....
#> 130                   490        20450 GO:00447....
#> 131                   490        20527 GO:00447....
#> 132                   490        20451 GO:00447....
#> 133                   490        12740 GO:00451....
#> 134                   490        12799 GO:00457....
#> 135                   490        12982 GO:00198....
#> 136                   490        13105 GO:00070....
#> 137                   490        13789 GO:00071....
#> 138                   490        14665   GO:1903046
#> 139                   490        14922   GO:0006954
#> 140                   490        14942 GO:00020....
#> 141                   490        15052   GO:0000209
#> 142                   490        15130   GO:0034097
#> 143                   490        13004 GO:00002....
#> 144                   490        13103 GO:00070....
#> 145                   490        15461   GO:0034097
#> 146                   490        15462 GO:00343....
#> 147                   490        15466 GO:00706....
#> 148                   490        16924 GO:00315....
#> 149                   490        18098 GO:00071....
#> 150                   490        17559 GO:00069....
#> 151                   490        18544 GO:00335....
#> 152                   490        18576   GO:0098542
#> 153                   490        20437 GO:00000....
#> 154                   490        18598 GO:00507....
#> 155                   490        20209   GO:0042221
#> 156                   490        20371 GO:00432....
#> 157                   490        20448 GO:00447....
#> 158                   490        20447 GO:00073....
#> 159                   490        15335   GO:0031577
#> 160                   490        15336 GO:00070....
#> 161                   490        24163 GO:00109....
#> 162                   490        23706 GO:00224....
#> 163                   490        24492 GO:00106....
#> 164                   490        22624 GO:00513....
#> 165                   490        20530 GO:00447....
#> 166                   490        20532 GO:00025....
#> 167                   490        20534 GO:00025....
#> 168                   490        20526 GO:00330....
#> 169                   490        21052 GO:00511....
#> 170                   490        21593 GO:00026....
#> 171                   490        22623 GO:00513....
#> 172                   490        20529 GO:00447....
#> 173                   490        22761 GO:00333....
#> 174                   490        22768 GO:00606....
#> 175                   490        23104 GO:00513....
#> 176                   490        10288   GO:0008150
#> 177                   490        16633 GO:00069....
#> 178                   490         1154 GO:00023....
#> 179                   490         2455 GO:00023....
#> 180                   490        12247   GO:0032502
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
#> [1] "2026-08-12T18:06:21.714345+00:00"
#> 
#> $meta$version
#> [1] "e114_eg62_p19_27110d83"
#> 
#> 
#> attr(,"EMMA_record")
#> attr(,"EMMA_record")$method
#> attr(,"EMMA_record")$method$call
#> gost(query = de_res_IFNg_vs_naive$SYMBOL, organism = "hsapiens", 
#>     correction_method = "fdr", custom_bg = gene_universe, sources = "GO:BP")
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
#> gene_universe
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
#> [1] "2026-08-12 18:06:20 UTC"
#> 
#> attr(,"EMMA_record")$session_info
#> NULL
#> 
#> attr(,"EMMA_record")$extra
#> list()
#> 
#> attr(,"EMMA_record")$emma_version
#> [1] "0.99.5"
#> 
```
