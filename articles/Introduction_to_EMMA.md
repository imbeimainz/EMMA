# The \`EMMA\` User's Guide

## Introduction

Functional Enrichment Analysis (FEA) is a key downstream step in omics
workflows, commonly applied after differential expression analysis to
support biological interpretation and generate pathway-level hypotheses.
A wide range of tools and methods are available, mainly
Over-Representation Analysis (ORA) (Khatri et al. 2012)
[doi:10.1371/journal.pcbi.1002375](https://doi.org/10.1371/journal.pcbi.1002375)
and Gene Set Enrichment Analysis (GSEA) (Subramanian et al. 2005)
[doi:10.1073/pnas.0506580102](https://doi.org/10.1073/pnas.0506580102),
leading to substantial heterogeneity in analytical choices and reported
results.

Despite its widespread use, FEA is often insufficiently documented
(Wijesooriya et al. 2022)
[doi:10.1371/journal.pcbi.1009935](https://doi.org/10.1371/journal.pcbi.1009935).
Critical parameters such as background gene sets or multiple testing
correction methods are frequently missing or inconsistently reported in
scientific papers, limiting reproducibility and interpretability.
Currently, no standardized framework exists to ensure transparent and
reproducible documentation of FEA workflows, comparable to the MIAME
guidelines (Brazma et al. 2001)
[doi:10.1038/ng1201-365](https://doi.org/10.1038/ng1201-365).

To address this gap, we introduce
*[EMMA](https://bioconductor.org/packages/3.24/EMMA)*, a framework that
automatically captures key analytical parameters and provenance
information during the execution of FEA methods.

This vignette demonstrates how `EMMA` integrates with existing tools
(e.g. *[clusterProfiler](https://bioconductor.org/packages/3.24/clusterProfiler)*,
*[topGO](https://bioconductor.org/packages/3.24/topGO)*,
*[Enrichr](https://bioconductor.org/packages/3.24/Enrichr)*,
*[gprofiler2](https://bioconductor.org/packages/3.24/gprofiler2)*) to
execute enrichment analyses while systematically capturing analysis
parameters and provenance information during runtime, returning
enrichment results **without altering their original format**, alongside
structured and reusable metadata.

### What do you get with `EMMA`?

Using `EMMA` allows you to:

- Record the exact function call and parameters used for FEA
- Automatically track annotation sources (e.g. organism, gene set
  database)
- Retain provenance directly within the results object
- Generate reproducible summaries of the analysis (e.g. Methods
  sections)
- Facilitate sharing of results together with their analysis context

### How does `EMMA` work?

`EMMA` works by wrapping an enrichment call, executing it, and capturing
relevant provenance information and parameters during runtime. The
recorded metadata is then attached directly to the result object using
R’s **attribute system**.

This approach enables `EMMA` to preserve provenance information
**without modifying the original result structure or introducing new
classes**, allowing users to continue working seamlessly with standard
outputs from existing tools.

While Bioconductor provides dedicated metadata slots for certain S4
classes (e.g. via
[`metadata()`](https://rdrr.io/pkg/S4Vectors/man/Annotated-class.html)),
these are not consistently available across all enrichment result types.
By relying on attributes, provenance information can be attached to any
result object regardless of its underlying class.

## Getting started

To install this package, start R and enter:

``` r

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")}

BiocManager::install("EMMA")
```

Once installed, the package can be loaded and attached to the current
workspace as follows:

``` r

library("EMMA")
```

## A new section here: TODO?

MAybe where we describe a schematics of the intuition overall? Like:
stepwise with bullet point - run DE - run FEA as usual, passing the call
(with a pipe or in a call itself) to EMMA_run - show how to retrieve
info (just the names) - summarizing the info - explaining it (in my
eyes, a “chunk not evaluated could be also good”) + a figure would be
fantastic with a simple diagram? Maybe a diagram that would show what
EMMA puts in and avoids you to take notes of?

## `EMMA` on the `macrophage` dataset

In the remainder of this vignette, we will illustrate the main features
of *[EMMA](https://bioconductor.org/packages/3.24/EMMA)* on a publicly
available dataset from Alasoo, et al. “Shared genetic effects on
chromatin and gene expression indicate a role for enhancer priming in
immune response”, published in Nature Genetics, January 2018 (Alasoo et
al. 2018)
[doi:10.1038/s41588-018-0046-7](https://doi.org/10.1038/s41588-018-0046-7).

The data is made available via the
*[macrophage](https://bioconductor.org/packages/3.24/macrophage)*
Bioconductor package, which contains the files output from the Salmon
quantification (version 0.12.0, with GENCODE v29 reference), as well as
the values summarized at the gene level, which we will use to exemplify.

In the `macrophage` experimental setting, the samples are available from
6 different donors, in 4 different conditions (naive, treated with
Interferon gamma, with SL1344, or with a combination of Interferon gamma
and SL1344).

Let’s start by loading all the necessary packages:

``` r

library("EMMA")

library("macrophage")
library("DESeq2")
library("org.Hs.eg.db")
library("clusterProfiler")
library("mosdef")
library("topGO")
library("GO.db")
```

We will show an example of how
*[EMMA](https://bioconductor.org/packages/3.24/EMMA)* fits into a
regular bulk RNA-seq data analysis workflow.

## Get a list of Differentially Expressed Genes

For this, we will load the `macrophage` data and perform Differential
Expression Analysis with
*[DESeq2](https://bioconductor.org/packages/3.24/DESeq2)*

``` r

# load data
data(gse, "macrophage")
# set up design
dds_macrophage <- DESeqDataSet(gse, design = ~ line + condition)
# preprocess
rownames(dds_macrophage) <- substr(rownames(dds_macrophage), 1, 15)
keep <- rowSums(counts(dds_macrophage) >= 10) >= 6

dds_macrophage <- dds_macrophage[keep, ]

# run DESeq
dds_macrophage <- DESeq(dds_macrophage)

# get de res for 1st contrast
IFNg_vs_naive <- results(dds_macrophage,
                         contrast = c("condition", "IFNg", "naive"),
                         lfcThreshold = 1, alpha = 0.05)
IFNg_vs_naive <- lfcShrink(dds_macrophage, coef = "condition_IFNg_vs_naive",
                           res = IFNg_vs_naive,
                           type = "apeglm")
IFNg_vs_naive$SYMBOL <- rowData(dds_macrophage)$SYMBOL

# sort by adjusted p value
de_res <- IFNg_vs_naive[order(IFNg_vs_naive$padj), ]
de_res <- de_res[!(is.na(de_res$padj)) & de_res$padj <= 0.05, ]

# set background gene list
gene_universe <- rownames(dds_macrophage)
```

## Perform Functional Enrichment Analysis (FEA)

### `EMMA` with available common packages/functions

Now that we have a list of DE genes for this contrast, we can perform
Functional Enrichment Analysis. In the following example, we will use
the function
[`enrichGO()`](https://rdrr.io/pkg/clusterProfiler/man/enrichGO.html)
from
*[clusterProfiler](https://bioconductor.org/packages/3.24/clusterProfiler)*

#### `EMMA_run()` :Capturing the recorded information

[`EMMA_run()`](../reference/EMMA_run.md) accepts a function call
(e.g. `enrichGO(...)`) and executes it as it is, while capturing the
associated parameters and provenance information:

``` r

# perform FEA, but with EMMA!
fea_res <- enrichGO(gene = rownames(de_res),
                    keyType = "ENSEMBL",
                    OrgDb = org.Hs.eg.db,
                    ont = "BP",
                    pAdjustMethod = "BH",
                    pvalueCutoff = 0.05,
                    qvalueCutoff = 0.1) |> 
  EMMA_run() # simply pipe your call to EMMA_run()
# check res
fea_res
```

    #> #
    #> # over-representation test
    #> #
    #> #...@organism     Homo sapiens 
    #> #...@ontology     BP 
    #> #...@keytype      ENTREZID 
    #> #...@gene     chr [1:925] "3659" "2634" "6539" "9934" "80832" "92610" "10068" "115362" ...
    #> #...pvalues adjusted by 'BH' with cutoff < 0.05
    #> #...604 enriched terms found
    #> 'data.frame':    604 obs. of  12 variables:
    #>  $ ID            : chr  "GO:0048002" "GO:0019884" "GO:0002478" "GO:0019882" ...
    #>  $ Description   : chr  "antigen processing and presentation of peptide antigen" "antigen processing and presentation of exogenous antigen" "antigen processing and presentation of exogenous peptide antigen" "antigen processing and presentation" ...
    #>  $ GeneRatio     : chr  "30/787" "25/787" "23/787" "34/787" ...
    #>  $ BgRatio       : chr  "68/18842" "45/18842" "39/18842" "104/18842" ...
    #>  $ RichFactor    : num  0.441 0.556 0.59 0.327 0.312 ...
    #>  $ FoldEnrichment: num  10.56 13.3 14.12 7.83 7.47 ...
    #>  $ zScore        : num  16.5 17.2 17.1 14.6 14.1 ...
    #>  $ pvalue        : num  9.75e-24 3.29e-23 2.79e-22 1.16e-21 6.45e-21 ...
    #>  $ p.adjust      : num  5.73e-20 9.67e-20 5.46e-19 1.71e-18 7.58e-18 ...
    #>  $ qvalue        : num  5.73e-20 9.67e-20 5.46e-19 1.71e-18 7.58e-18 ...
    #>  $ geneID        : chr  "ENSG00000196126/ENSG00000204287/ENSG00000237541/ENSG00000179344/ENSG00000204525/ENSG00000198502/ENSG00000204252"| __truncated__ "ENSG00000196126/ENSG00000204287/ENSG00000237541/ENSG00000179344/ENSG00000204525/ENSG00000198502/ENSG00000158477"| __truncated__ "ENSG00000196126/ENSG00000204287/ENSG00000237541/ENSG00000179344/ENSG00000204525/ENSG00000198502/ENSG00000204252"| __truncated__ "ENSG00000196126/ENSG00000204287/ENSG00000237541/ENSG00000179344/ENSG00000204525/ENSG00000198502/ENSG00000158477"| __truncated__ ...
    #>  $ Count         : int  30 25 23 34 34 17 17 59 59 67 ...
    #> #...Citation
    #> S Xu, E Hu, Y Cai, Z Xie, X Luo, L Zhan, W Tang, Q Wang, B Liu, R Wang, W Xie, T Wu, L Xie, G Yu. Using clusterProfiler to characterize multiomics data. Nature Protocols. 2024, 19(11):3292-3320

… or you can simply wrap [`EMMA_run()`](../reference/EMMA_run.md) around
your call:

``` r

# you can also pass the function name and its namespace
# e.g. `clusterProfiler::enrichGO(...)`
fea_res <- EMMA_run(clusterProfiler::enrichGO(
                    gene = rownames(de_res),
                    keyType = "ENSEMBL",
                    OrgDb = org.Hs.eg.db,
                    ont = "BP",
                    pAdjustMethod = "BH",
                    pvalueCutoff = 0.05,
                    qvalueCutoff = 0.1,
                    readable = TRUE))
```

As you can see, `EMMA` returns the FEA results in their
**native/standard** format. `EMMA` also warns you about good practices
when performing FEA, like in this example, we didn’t define a list of
background genes (which can influence the results), so we get warned
about that.

#### `EMMA_show()` : Summarizing the recorded information

To get a quick summary of what `EMMA` captured while we ran the
analysis, we use [`EMMA_show()`](../reference/EMMA_show.md):

``` r

EMMA_show(fea_res)
```

    #> Number of Pathways:  604 
    #> Call:  enrichGO(gene = rownames(de_res), keyType = "ENSEMBL", OrgDb = org.Hs.eg.db,      ont = "BP", pAdjustMethod = "BH", pvalueCutoff = 0.05, qvalueCutoff = 0.1)  
    #> Wrapper:  FALSE  
    #> Package:  clusterProfiler v. 4.21.0  
    #> Organism :  Homo sapiens  
    #> Gene set library :  GO  
    #> Gene set library version :  3.23.1

`EMMA` attaches the captured metadata to the attributes of the results
object. That’s why it is always a good practice to save the original
results, and not only the subsets of interest.

#### `EMMA_get_record()` : Retrieving the recorded information

To access the full recorded information, we use
[`EMMA_get_record()`](../reference/EMMA_get_record.md):

``` r

emma_record <- EMMA_get_record(fea_res)

# get all the record
emma_record
```

    #> $method
    #> $method$call
    #> enrichGO(gene = rownames(de_res), keyType = "ENSEMBL", OrgDb = org.Hs.eg.db, 
    #>     ont = "BP", pAdjustMethod = "BH", pvalueCutoff = 0.05, qvalueCutoff = 0.1)
    #> 
    #> $method$function_name
    #> [1] "enrichGO"
    #> 
    #> $method$package_name
    #> [1] "clusterProfiler"
    #> 
    #> $method$package_version
    #> [1] "4.21.0"
    #> 
    #> $method$wrapped_function
    #> NULL
    #> 
    #> $method$wrapped_package
    #> NULL
    #> 
    #> $method$wrapper
    #> [1] FALSE
    #> 
    #> 
    #> $input
    #> $input$arguments
    #> $input$arguments$gene
    #>    [1] "ENSG00000125347" "ENSG00000162645" "ENSG00000111181" "ENSG00000174944"
    #>    [5] "ENSG00000100336" "ENSG00000145365" "ENSG00000137496" "ENSG00000154451"
    #>    [9] "ENSG00000129244" "ENSG00000231389" "ENSG00000204257" "ENSG00000100342"
    #>   [13] "ENSG00000162654" "ENSG00000133321" "ENSG00000128284" "ENSG00000134470"
    #>   [17] "ENSG00000172399" "ENSG00000164509" "ENSG00000225492" "ENSG00000204267"
    #>   [21] "ENSG00000254838" "ENSG00000131203" "ENSG00000213886" "ENSG00000100911"
    #>   [25] "ENSG00000168394" "ENSG00000242574" "ENSG00000234518" "ENSG00000163568"
    #>   [29] "ENSG00000213626" "ENSG00000183734" "ENSG00000101017" "ENSG00000140105"
    #>   [33] "ENSG00000117228" "ENSG00000244731" "ENSG00000019582" "ENSG00000204252"
    #>   [37] "ENSG00000270547" "ENSG00000089041" "ENSG00000179583" "ENSG00000121380"
    #>   [41] "ENSG00000136436" "ENSG00000170989" "ENSG00000168899" "ENSG00000153012"
    #>   [45] "ENSG00000140511" "ENSG00000185338" "ENSG00000174749" "ENSG00000188820"
    #>   [49] "ENSG00000120217" "ENSG00000188906" "ENSG00000204287" "ENSG00000010030"
    #>   [53] "ENSG00000108387" "ENSG00000086300" "ENSG00000146859" "ENSG00000131979"
    #>   [57] "ENSG00000256262" "ENSG00000198520" "ENSG00000096996" "ENSG00000177675"
    #>   [61] "ENSG00000226025" "ENSG00000113263" "ENSG00000169248" "ENSG00000166002"
    #>   [65] "ENSG00000117226" "ENSG00000026751" "ENSG00000196329" "ENSG00000272941"
    #>   [69] "ENSG00000240065" "ENSG00000159871" "ENSG00000186088" "ENSG00000124785"
    #>   [73] "ENSG00000224389" "ENSG00000116663" "ENSG00000004468" "ENSG00000197646"
    #>   [77] "ENSG00000164136" "ENSG00000225342" "ENSG00000149131" "ENSG00000223749"
    #>   [81] "ENSG00000261644" "ENSG00000008517" "ENSG00000128335" "ENSG00000152766"
    #>   [85] "ENSG00000186439" "ENSG00000235750" "ENSG00000198814" "ENSG00000089692"
    #>   [89] "ENSG00000184588" "ENSG00000078081" "ENSG00000226004" "ENSG00000223865"
    #>   [93] "ENSG00000073861" "ENSG00000164308" "ENSG00000173369" "ENSG00000224875"
    #>   [97] "ENSG00000169245" "ENSG00000196126" "ENSG00000135052" "ENSG00000167207"
    #>  [101] "ENSG00000110852" "ENSG00000113555" "ENSG00000152229" "ENSG00000204642"
    #>  [105] "ENSG00000233834" "ENSG00000079385" "ENSG00000153823" "ENSG00000123146"
    #>  [109] "ENSG00000131482" "ENSG00000179344" "ENSG00000224968" "ENSG00000181374"
    #>  [113] "ENSG00000186470" "ENSG00000185518" "ENSG00000198502" "ENSG00000115956"
    #>  [117] "ENSG00000234745" "ENSG00000167208" "ENSG00000185215" "ENSG00000126016"
    #>  [121] "ENSG00000197992" "ENSG00000241886" "ENSG00000171509" "ENSG00000139597"
    #>  [125] "ENSG00000000971" "ENSG00000019991" "ENSG00000206337" "ENSG00000183762"
    #>  [129] "ENSG00000152207" "ENSG00000253838" "ENSG00000188404" "ENSG00000213809"
    #>  [133] "ENSG00000167550" "ENSG00000140853" "ENSG00000121858" "ENSG00000135604"
    #>  [137] "ENSG00000279805" "ENSG00000159363" "ENSG00000092010" "ENSG00000243649"
    #>  [141] "ENSG00000185291" "ENSG00000026950" "ENSG00000231528" "ENSG00000164691"
    #>  [145] "ENSG00000136867" "ENSG00000274029" "ENSG00000229391" "ENSG00000128203"
    #>  [149] "ENSG00000206341" "ENSG00000204592" "ENSG00000255987" "ENSG00000102794"
    #>  [153] "ENSG00000236120" "ENSG00000224789" "ENSG00000002549" "ENSG00000141574"
    #>  [157] "ENSG00000168062" "ENSG00000118777" "ENSG00000268088" "ENSG00000153064"
    #>  [161] "ENSG00000213316" "ENSG00000138755" "ENSG00000182508" "ENSG00000172183"
    #>  [165] "ENSG00000090539" "ENSG00000122877" "ENSG00000155011" "ENSG00000004799"
    #>  [169] "ENSG00000221963" "ENSG00000162772" "ENSG00000188916" "ENSG00000267074"
    #>  [173] "ENSG00000160190" "ENSG00000260943" "ENSG00000268758" "ENSG00000141655"
    #>  [177] "ENSG00000155792" "ENSG00000157445" "ENSG00000180616" "ENSG00000144649"
    #>  [181] "ENSG00000164715" "ENSG00000206503" "ENSG00000123609" "ENSG00000175305"
    #>  [185] "ENSG00000188676" "ENSG00000117115" "ENSG00000151364" "ENSG00000183160"
    #>  [189] "ENSG00000273300" "ENSG00000142549" "ENSG00000233901" "ENSG00000123240"
    #>  [193] "ENSG00000148798" "ENSG00000115415" "ENSG00000213512" "ENSG00000198785"
    #>  [197] "ENSG00000163599" "ENSG00000177409" "ENSG00000172954" "ENSG00000162931"
    #>  [201] "ENSG00000063180" "ENSG00000182541" "ENSG00000243753" "ENSG00000189057"
    #>  [205] "ENSG00000204525" "ENSG00000107957" "ENSG00000177807" "ENSG00000182782"
    #>  [209] "ENSG00000197536" "ENSG00000198736" "ENSG00000096968" "ENSG00000198829"
    #>  [213] "ENSG00000168329" "ENSG00000205220" "ENSG00000110665" "ENSG00000272196"
    #>  [217] "ENSG00000272567" "ENSG00000255819" "ENSG00000127951" "ENSG00000013374"
    #>  [221] "ENSG00000231808" "ENSG00000183856" "ENSG00000227531" "ENSG00000135744"
    #>  [225] "ENSG00000255398" "ENSG00000002933" "ENSG00000151651" "ENSG00000137193"
    #>  [229] "ENSG00000130489" "ENSG00000135148" "ENSG00000135424" "ENSG00000242258"
    #>  [233] "ENSG00000121270" "ENSG00000233621" "ENSG00000232629" "ENSG00000238105"
    #>  [237] "ENSG00000178726" "ENSG00000072952" "ENSG00000186469" "ENSG00000158270"
    #>  [241] "ENSG00000197721" "ENSG00000106565" "ENSG00000140379" "ENSG00000165949"
    #>  [245] "ENSG00000138119" "ENSG00000187672" "ENSG00000168658" "ENSG00000173762"
    #>  [249] "ENSG00000236256" "ENSG00000127954" "ENSG00000088992" "ENSG00000070915"
    #>  [253] "ENSG00000104312" "ENSG00000131401" "ENSG00000176485" "ENSG00000101916"
    #>  [257] "ENSG00000049089" "ENSG00000007968" "ENSG00000244255" "ENSG00000119547"
    #>  [261] "ENSG00000147647" "ENSG00000154359" "ENSG00000156587" "ENSG00000240184"
    #>  [265] "ENSG00000170873" "ENSG00000254704" "ENSG00000129173" "ENSG00000278910"
    #>  [269] "ENSG00000131747" "ENSG00000270426" "ENSG00000111801" "ENSG00000110328"
    #>  [273] "ENSG00000104951" "ENSG00000179144" "ENSG00000257093" "ENSG00000172818"
    #>  [277] "ENSG00000126838" "ENSG00000261971" "ENSG00000123685" "ENSG00000166278"
    #>  [281] "ENSG00000067715" "ENSG00000250722" "ENSG00000102524" "ENSG00000018280"
    #>  [285] "ENSG00000170581" "ENSG00000182580" "ENSG00000171551" "ENSG00000147614"
    #>  [289] "ENSG00000230795" "ENSG00000204622" "ENSG00000108688" "ENSG00000173210"
    #>  [293] "ENSG00000275688" "ENSG00000239642" "ENSG00000277481" "ENSG00000169508"
    #>  [297] "ENSG00000151572" "ENSG00000232591" "ENSG00000142621" "ENSG00000236567"
    #>  [301] "ENSG00000231925" "ENSG00000261222" "ENSG00000099250" "ENSG00000123095"
    #>  [305] "ENSG00000197272" "ENSG00000145390" "ENSG00000260580" "ENSG00000205436"
    #>  [309] "ENSG00000026103" "ENSG00000151726" "ENSG00000106541" "ENSG00000152760"
    #>  [313] "ENSG00000204264" "ENSG00000101412" "ENSG00000186417" "ENSG00000068079"
    #>  [317] "ENSG00000140749" "ENSG00000249700" "ENSG00000114127" "ENSG00000178562"
    #>  [321] "ENSG00000166220" "ENSG00000237988" "ENSG00000123700" "ENSG00000131471"
    #>  [325] "ENSG00000153898" "ENSG00000203709" "ENSG00000101057" "ENSG00000270120"
    #>  [329] "ENSG00000145349" "ENSG00000025708" "ENSG00000241106" "ENSG00000163016"
    #>  [333] "ENSG00000196735" "ENSG00000162692" "ENSG00000140465" "ENSG00000160460"
    #>  [337] "ENSG00000106992" "ENSG00000185201" "ENSG00000090339" "ENSG00000163666"
    #>  [341] "ENSG00000049130" "ENSG00000138134" "ENSG00000271581" "ENSG00000214212"
    #>  [345] "ENSG00000099377" "ENSG00000065328" "ENSG00000229754" "ENSG00000257167"
    #>  [349] "ENSG00000079156" "ENSG00000284690" "ENSG00000149577" "ENSG00000170915"
    #>  [353] "ENSG00000130940" "ENSG00000103154" "ENSG00000112139" "ENSG00000131153"
    #>  [357] "ENSG00000154146" "ENSG00000169994" "ENSG00000175643" "ENSG00000167680"
    #>  [361] "ENSG00000166578" "ENSG00000136514" "ENSG00000136826" "ENSG00000157216"
    #>  [365] "ENSG00000261618" "ENSG00000180139" "ENSG00000074660" "ENSG00000226791"
    #>  [369] "ENSG00000124191" "ENSG00000153094" "ENSG00000157017" "ENSG00000254017"
    #>  [373] "ENSG00000154099" "ENSG00000205846" "ENSG00000047365" "ENSG00000185499"
    #>  [377] "ENSG00000255491" "ENSG00000029153" "ENSG00000275718" "ENSG00000152253"
    #>  [381] "ENSG00000172738" "ENSG00000243811" "ENSG00000124256" "ENSG00000146090"
    #>  [385] "ENSG00000253414" "ENSG00000070190" "ENSG00000198959" "ENSG00000075399"
    #>  [389] "ENSG00000157551" "ENSG00000043143" "ENSG00000137767" "ENSG00000164124"
    #>  [393] "ENSG00000204577" "ENSG00000171848" "ENSG00000179603" "ENSG00000241220"
    #>  [397] "ENSG00000123080" "ENSG00000148484" "ENSG00000229162" "ENSG00000184678"
    #>  [401] "ENSG00000185885" "ENSG00000001561" "ENSG00000020577" "ENSG00000156219"
    #>  [405] "ENSG00000090554" "ENSG00000120337" "ENSG00000121594" "ENSG00000104518"
    #>  [409] "ENSG00000285446" "ENSG00000011677" "ENSG00000285744" "ENSG00000240891"
    #>  [413] "ENSG00000279882" "ENSG00000213373" "ENSG00000079263" "ENSG00000053108"
    #>  [417] "ENSG00000132530" "ENSG00000057252" "ENSG00000146476" "ENSG00000176890"
    #>  [421] "ENSG00000093009" "ENSG00000137819" "ENSG00000119686" "ENSG00000103489"
    #>  [425] "ENSG00000233746" "ENSG00000042286" "ENSG00000140280" "ENSG00000188389"
    #>  [429] "ENSG00000251230" "ENSG00000144227" "ENSG00000162367" "ENSG00000241978"
    #>  [433] "ENSG00000162444" "ENSG00000238005" "ENSG00000116016" "ENSG00000064201"
    #>  [437] "ENSG00000225864" "ENSG00000261888" "ENSG00000132274" "ENSG00000127399"
    #>  [441] "ENSG00000164045" "ENSG00000167371" "ENSG00000140464" "ENSG00000108950"
    #>  [445] "ENSG00000100368" "ENSG00000119943" "ENSG00000146072" "ENSG00000094804"
    #>  [449] "ENSG00000144354" "ENSG00000135549" "ENSG00000075142" "ENSG00000085999"
    #>  [453] "ENSG00000116514" "ENSG00000173821" "ENSG00000165935" "ENSG00000227017"
    #>  [457] "ENSG00000166710" "ENSG00000165244" "ENSG00000166803" "ENSG00000285761"
    #>  [461] "ENSG00000108700" "ENSG00000128383" "ENSG00000125730" "ENSG00000162739"
    #>  [465] "ENSG00000092853" "ENSG00000221971" "ENSG00000274461" "ENSG00000239713"
    #>  [469] "ENSG00000232124" "ENSG00000132514" "ENSG00000166106" "ENSG00000132963"
    #>  [473] "ENSG00000164125" "ENSG00000186074" "ENSG00000076356" "ENSG00000254859"
    #>  [477] "ENSG00000103313" "ENSG00000161929" "ENSG00000150681" "ENSG00000224099"
    #>  [481] "ENSG00000181409" "ENSG00000189171" "ENSG00000119917" "ENSG00000276980"
    #>  [485] "ENSG00000230438" "ENSG00000058335" "ENSG00000196878" "ENSG00000168405"
    #>  [489] "ENSG00000081923" "ENSG00000174123" "ENSG00000154122" "ENSG00000163874"
    #>  [493] "ENSG00000121797" "ENSG00000085563" "ENSG00000140534" "ENSG00000076003"
    #>  [497] "ENSG00000163131" "ENSG00000167914" "ENSG00000159231" "ENSG00000133106"
    #>  [501] "ENSG00000160298" "ENSG00000236254" "ENSG00000224666" "ENSG00000105639"
    #>  [505] "ENSG00000178685" "ENSG00000083799" "ENSG00000104894" "ENSG00000088881"
    #>  [509] "ENSG00000160957" "ENSG00000227766" "ENSG00000178573" "ENSG00000272463"
    #>  [513] "ENSG00000108679" "ENSG00000164684" "ENSG00000104760" "ENSG00000143452"
    #>  [517] "ENSG00000145757" "ENSG00000276411" "ENSG00000135124" "ENSG00000177465"
    #>  [521] "ENSG00000111665" "ENSG00000163913" "ENSG00000133800" "ENSG00000163803"
    #>  [525] "ENSG00000153071" "ENSG00000166508" "ENSG00000172159" "ENSG00000203805"
    #>  [529] "ENSG00000109756" "ENSG00000119922" "ENSG00000196954" "ENSG00000144837"
    #>  [533] "ENSG00000117594" "ENSG00000023330" "ENSG00000144136" "ENSG00000255221"
    #>  [537] "ENSG00000136048" "ENSG00000237505" "ENSG00000035720" "ENSG00000167900"
    #>  [541] "ENSG00000059378" "ENSG00000135899" "ENSG00000158477" "ENSG00000124201"
    #>  [545] "ENSG00000137310" "ENSG00000112394" "ENSG00000077063" "ENSG00000205045"
    #>  [549] "ENSG00000230387" "ENSG00000139832" "ENSG00000065911" "ENSG00000174371"
    #>  [553] "ENSG00000006747" "ENSG00000122547" "ENSG00000169136" "ENSG00000140563"
    #>  [557] "ENSG00000185507" "ENSG00000162496" "ENSG00000226125" "ENSG00000177721"
    #>  [561] "ENSG00000226328" "ENSG00000136982" "ENSG00000204397" "ENSG00000119969"
    #>  [565] "ENSG00000185880" "ENSG00000160326" "ENSG00000108622" "ENSG00000253161"
    #>  [569] "ENSG00000184221" "ENSG00000165806" "ENSG00000104738" "ENSG00000169604"
    #>  [573] "ENSG00000100206" "ENSG00000171320" "ENSG00000285454" "ENSG00000169418"
    #>  [577] "ENSG00000184497" "ENSG00000186185" "ENSG00000167513" "ENSG00000081985"
    #>  [581] "ENSG00000186871" "ENSG00000198203" "ENSG00000104112" "ENSG00000133687"
    #>  [585] "ENSG00000134321" "ENSG00000237352" "ENSG00000125810" "ENSG00000183153"
    #>  [589] "ENSG00000162337" "ENSG00000230225" "ENSG00000073111" "ENSG00000022567"
    #>  [593] "ENSG00000168334" "ENSG00000104974" "ENSG00000110108" "ENSG00000275630"
    #>  [597] "ENSG00000163808" "ENSG00000233952" "ENSG00000161888" "ENSG00000148429"
    #>  [601] "ENSG00000138640" "ENSG00000134207" "ENSG00000120436" "ENSG00000183578"
    #>  [605] "ENSG00000100985" "ENSG00000137959" "ENSG00000168496" "ENSG00000179776"
    #>  [609] "ENSG00000254343" "ENSG00000256043" "ENSG00000197520" "ENSG00000224083"
    #>  [613] "ENSG00000103642" "ENSG00000136960" "ENSG00000239282" "ENSG00000279811"
    #>  [617] "ENSG00000023171" "ENSG00000261472" "ENSG00000232912" "ENSG00000173198"
    #>  [621] "ENSG00000144118" "ENSG00000180817" "ENSG00000253141" "ENSG00000145780"
    #>  [625] "ENSG00000282608" "ENSG00000152939" "ENSG00000104044" "ENSG00000170271"
    #>  [629] "ENSG00000034510" "ENSG00000124508" "ENSG00000182326" "ENSG00000078401"
    #>  [633] "ENSG00000139178" "ENSG00000152270" "ENSG00000150630" "ENSG00000100162"
    #>  [637] "ENSG00000115267" "ENSG00000147166" "ENSG00000235852" "ENSG00000274370"
    #>  [641] "ENSG00000256713" "ENSG00000109805" "ENSG00000166920" "ENSG00000100226"
    #>  [645] "ENSG00000228106" "ENSG00000149212" "ENSG00000185924" "ENSG00000169439"
    #>  [649] "ENSG00000146670" "ENSG00000137078" "ENSG00000250264" "ENSG00000073737"
    #>  [653] "ENSG00000117090" "ENSG00000133313" "ENSG00000158517" "ENSG00000122952"
    #>  [657] "ENSG00000163840" "ENSG00000123572" "ENSG00000127564" "ENSG00000283648"
    #>  [661] "ENSG00000188042" "ENSG00000227510" "ENSG00000248187" "ENSG00000134291"
    #>  [665] "ENSG00000104147" "ENSG00000134627" "ENSG00000183347" "ENSG00000208005"
    #>  [669] "ENSG00000170312" "ENSG00000068615" "ENSG00000197081" "ENSG00000168309"
    #>  [673] "ENSG00000254528" "ENSG00000116544" "ENSG00000186340" "ENSG00000164292"
    #>  [677] "ENSG00000089685" "ENSG00000141682" "ENSG00000197077" "ENSG00000158715"
    #>  [681] "ENSG00000177098" "ENSG00000113070" "ENSG00000196584" "ENSG00000114737"
    #>  [685] "ENSG00000284194" "ENSG00000113749" "ENSG00000013364" "ENSG00000239998"
    #>  [689] "ENSG00000130066" "ENSG00000278764" "ENSG00000214826" "ENSG00000186810"
    #>  [693] "ENSG00000166224" "ENSG00000134256" "ENSG00000011426" "ENSG00000136689"
    #>  [697] "ENSG00000228716" "ENSG00000185736" "ENSG00000161217" "ENSG00000139192"
    #>  [701] "ENSG00000155287" "ENSG00000110079" "ENSG00000064932" "ENSG00000099860"
    #>  [705] "ENSG00000054219" "ENSG00000012048" "ENSG00000110881" "ENSG00000143476"
    #>  [709] "ENSG00000198901" "ENSG00000145362" "ENSG00000204616" "ENSG00000137628"
    #>  [713] "ENSG00000164485" "ENSG00000104805" "ENSG00000198756" "ENSG00000083097"
    #>  [717] "ENSG00000175130" "ENSG00000254521" "ENSG00000197448" "ENSG00000120262"
    #>  [721] "ENSG00000155324" "ENSG00000266835" "ENSG00000109674" "ENSG00000151725"
    #>  [725] "ENSG00000155158" "ENSG00000185022" "ENSG00000223953" "ENSG00000113583"
    #>  [729] "ENSG00000036565" "ENSG00000112782" "ENSG00000237424" "ENSG00000253968"
    #>  [733] "ENSG00000154642" "ENSG00000189127" "ENSG00000227467" "ENSG00000148773"
    #>  [737] "ENSG00000267500" "ENSG00000133816" "ENSG00000145386" "ENSG00000257743"
    #>  [741] "ENSG00000237927" "ENSG00000112320" "ENSG00000159618" "ENSG00000092470"
    #>  [745] "ENSG00000062282" "ENSG00000138160" "ENSG00000197747" "ENSG00000121690"
    #>  [749] "ENSG00000256427" "ENSG00000125869" "ENSG00000237711" "ENSG00000125148"
    #>  [753] "ENSG00000226742" "ENSG00000273301" "ENSG00000105664" "ENSG00000284691"
    #>  [757] "ENSG00000108960" "ENSG00000178078" "ENSG00000206561" "ENSG00000179044"
    #>  [761] "ENSG00000164109" "ENSG00000135636" "ENSG00000122694" "ENSG00000127533"
    #>  [765] "ENSG00000159403" "ENSG00000185433" "ENSG00000162745" "ENSG00000170448"
    #>  [769] "ENSG00000154639" "ENSG00000142089" "ENSG00000162512" "ENSG00000092345"
    #>  [773] "ENSG00000110848" "ENSG00000154783" "ENSG00000254054" "ENSG00000167992"
    #>  [777] "ENSG00000258976" "ENSG00000145708" "ENSG00000280623" "ENSG00000085840"
    #>  [781] "ENSG00000169891" "ENSG00000225964" "ENSG00000278330" "ENSG00000138744"
    #>  [785] "ENSG00000159259" "ENSG00000065427" "ENSG00000040531" "ENSG00000169758"
    #>  [789] "ENSG00000134042" "ENSG00000075240" "ENSG00000204632" "ENSG00000100628"
    #>  [793] "ENSG00000082074" "ENSG00000229859" "ENSG00000158714" "ENSG00000168546"
    #>  [797] "ENSG00000143924" "ENSG00000173406" "ENSG00000070501" "ENSG00000140297"
    #>  [801] "ENSG00000157827" "ENSG00000186815" "ENSG00000106976" "ENSG00000170439"
    #>  [805] "ENSG00000171044" "ENSG00000198604" "ENSG00000123689" "ENSG00000125355"
    #>  [809] "ENSG00000158481" "ENSG00000230521" "ENSG00000158813" "ENSG00000171115"
    #>  [813] "ENSG00000158186" "ENSG00000187554" "ENSG00000099998" "ENSG00000261884"
    #>  [817] "ENSG00000182487" "ENSG00000205726" "ENSG00000146918" "ENSG00000072858"
    #>  [821] "ENSG00000164695" "ENSG00000138162" "ENSG00000163958" "ENSG00000050767"
    #>  [825] "ENSG00000156273" "ENSG00000171522" "ENSG00000196668" "ENSG00000146425"
    #>  [829] "ENSG00000237541" "ENSG00000099985" "ENSG00000260528" "ENSG00000143228"
    #>  [833] "ENSG00000149573" "ENSG00000104856" "ENSG00000113916" "ENSG00000156414"
    #>  [837] "ENSG00000175175" "ENSG00000100479" "ENSG00000275385" "ENSG00000134326"
    #>  [841] "ENSG00000038427" "ENSG00000204161" "ENSG00000249816" "ENSG00000137804"
    #>  [845] "ENSG00000189067" "ENSG00000075218" "ENSG00000250240" "ENSG00000276043"
    #>  [849] "ENSG00000248751" "ENSG00000282572" "ENSG00000231509" "ENSG00000264963"
    #>  [853] "ENSG00000080986" "ENSG00000165178" "ENSG00000171241" "ENSG00000010818"
    #>  [857] "ENSG00000196911" "ENSG00000280649" "ENSG00000178999" "ENSG00000099958"
    #>  [861] "ENSG00000271503" "ENSG00000162520" "ENSG00000254087" "ENSG00000100297"
    #>  [865] "ENSG00000125900" "ENSG00000168016" "ENSG00000106952" "ENSG00000123219"
    #>  [869] "ENSG00000168811" "ENSG00000197093" "ENSG00000075275" "ENSG00000196684"
    #>  [873] "ENSG00000249249" "ENSG00000111335" "ENSG00000121152" "ENSG00000163735"
    #>  [877] "ENSG00000187068" "ENSG00000229183" "ENSG00000255833" "ENSG00000163564"
    #>  [881] "ENSG00000047579" "ENSG00000168268" "ENSG00000152778" "ENSG00000165071"
    #>  [885] "ENSG00000268061" "ENSG00000077152" "ENSG00000203799" "ENSG00000128965"
    #>  [889] "ENSG00000126217" "ENSG00000117632" "ENSG00000238045" "ENSG00000279296"
    #>  [893] "ENSG00000135821" "ENSG00000162063" "ENSG00000186854" "ENSG00000164736"
    #>  [897] "ENSG00000123124" "ENSG00000197275" "ENSG00000244701" "ENSG00000164300"
    #>  [901] "ENSG00000263050" "ENSG00000123610" "ENSG00000142583" "ENSG00000008516"
    #>  [905] "ENSG00000188282" "ENSG00000136044" "ENSG00000156970" "ENSG00000188707"
    #>  [909] "ENSG00000151948" "ENSG00000188343" "ENSG00000066735" "ENSG00000173193"
    #>  [913] "ENSG00000198719" "ENSG00000196664" "ENSG00000085265" "ENSG00000100490"
    #>  [917] "ENSG00000278177" "ENSG00000127561" "ENSG00000142405" "ENSG00000279960"
    #>  [921] "ENSG00000169607" "ENSG00000229950" "ENSG00000161714" "ENSG00000278969"
    #>  [925] "ENSG00000269583" "ENSG00000135378" "ENSG00000118492" "ENSG00000243414"
    #>  [929] "ENSG00000081803" "ENSG00000117724" "ENSG00000163624" "ENSG00000076248"
    #>  [933] "ENSG00000249173" "ENSG00000137807" "ENSG00000184371" "ENSG00000186918"
    #>  [937] "ENSG00000224721" "ENSG00000227463" "ENSG00000162241" "ENSG00000226979"
    #>  [941] "ENSG00000123485" "ENSG00000099256" "ENSG00000075702" "ENSG00000268027"
    #>  [945] "ENSG00000143819" "ENSG00000099282" "ENSG00000113249" "ENSG00000028116"
    #>  [949] "ENSG00000226453" "ENSG00000175445" "ENSG00000119508" "ENSG00000273216"
    #>  [953] "ENSG00000158806" "ENSG00000162981" "ENSG00000111817" "ENSG00000229271"
    #>  [957] "ENSG00000197769" "ENSG00000033867" "ENSG00000141497" "ENSG00000154920"
    #>  [961] "ENSG00000241912" "ENSG00000123992" "ENSG00000157873" "ENSG00000136560"
    #>  [965] "ENSG00000179021" "ENSG00000139899" "ENSG00000222179" "ENSG00000197472"
    #>  [969] "ENSG00000176659" "ENSG00000213071" "ENSG00000196782" "ENSG00000112039"
    #>  [973] "ENSG00000041880" "ENSG00000178922" "ENSG00000131018" "ENSG00000166033"
    #>  [977] "ENSG00000111331" "ENSG00000127586" "ENSG00000273604" "ENSG00000114698"
    #>  [981] "ENSG00000123096" "ENSG00000106089" "ENSG00000267712" "ENSG00000168890"
    #>  [985] "ENSG00000138496" "ENSG00000153208" "ENSG00000144460" "ENSG00000165312"
    #>  [989] "ENSG00000075618" "ENSG00000203446" "ENSG00000280798" "ENSG00000229056"
    #>  [993] "ENSG00000118507" "ENSG00000141086" "ENSG00000089159" "ENSG00000168916"
    #>  [997] "ENSG00000176076" "ENSG00000105967" "ENSG00000104432" "ENSG00000135047"
    #> [1001] "ENSG00000091129" "ENSG00000224137" "ENSG00000082781" "ENSG00000163421"
    #> [1005] "ENSG00000112096" "ENSG00000060656" "ENSG00000228340" "ENSG00000129422"
    #> [1009] "ENSG00000224769" "ENSG00000100344" "ENSG00000184675" "ENSG00000160949"
    #> [1013] "ENSG00000183943" "ENSG00000126246" "ENSG00000110315" "ENSG00000177575"
    #> [1017] "ENSG00000141441" "ENSG00000166483" "ENSG00000092445" "ENSG00000188313"
    #> [1021] "ENSG00000112149" "ENSG00000101003" "ENSG00000269927" "ENSG00000137265"
    #> 
    #> $input$arguments$keyType
    #> [1] "ENSEMBL"
    #> 
    #> $input$arguments$OrgDb
    #> OrgDb object:
    #> | DBSCHEMAVERSION: 2.1
    #> | Db type: OrgDb
    #> | Supporting package: AnnotationDbi
    #> | DBSCHEMA: HUMAN_DB
    #> | ORGANISM: Homo sapiens
    #> | SPECIES: Human
    #> | EGSOURCEDATE: 2026-Mar18
    #> | EGSOURCENAME: Entrez Gene
    #> | EGSOURCEURL: ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
    #> | CENTRALID: EG
    #> | TAXID: 9606
    #> | GOSOURCENAME: Gene Ontology
    #> | GOSOURCEURL: https://current.geneontology.org/ontology/go-basic.obo
    #> | GOSOURCEDATE: 2026-01-23
    #> | GOEGSOURCEDATE: 2026-Mar18
    #> | GOEGSOURCENAME: Entrez Gene
    #> | GOEGSOURCEURL: ftp://ftp.ncbi.nlm.nih.gov/gene/DATA
    #> | KEGGSOURCENAME: KEGG GENOME
    #> | KEGGSOURCEURL: ftp://ftp.genome.jp/pub/kegg/genomes
    #> | KEGGSOURCEDATE: 2011-Mar15
    #> | GPSOURCENAME: UCSC Genome Bioinformatics (Homo sapiens)
    #> | GPSOURCEURL: ftp://hgdownload.cse.ucsc.edu/goldenPath/hg38/database
    #> | GPSOURCEDATE: UTC-Mar19
    #> | ENSOURCEDATE: 2025-Sep03
    #> | ENSOURCENAME: Ensembl
    #> | ENSOURCEURL: ftp://ftp.ensembl.org/pub/current_fasta
    #> | UPSOURCENAME: Uniprot
    #> | UPSOURCEURL: http://www.UniProt.org/
    #> | UPSOURCEDATE: Fri Mar 20 10:22:53 2026

    #> 
    #> $input$arguments$ont
    #> [1] "BP"
    #> 
    #> $input$arguments$pAdjustMethod
    #> [1] "BH"
    #> 
    #> $input$arguments$pvalueCutoff
    #> [1] 0.05
    #> 
    #> $input$arguments$qvalueCutoff
    #> [1] 0.1
    #> 
    #> 
    #> 
    #> $annotation
    #> $annotation$organism
    #> [1] "Homo sapiens"
    #> 
    #> $annotation$gene_set_db
    #> [1] "GO"
    #> 
    #> $annotation$gene_set_db_version
    #> [1] "3.23.1"
    #> 
    #> 
    #> $timestamp
    #> [1] "2026-05-11 19:17:14 CEST"
    #> 
    #> $session_info
    #> R version 4.6.0 (2026-04-24)
    #> Platform: aarch64-apple-darwin23
    #> Running under: macOS Sequoia 15.7.2
    #> 
    #> Matrix products: default
    #> BLAS:   /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRblas.0.dylib 
    #> LAPACK: /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
    #> 
    #> locale:
    #> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    #> 
    #> time zone: Europe/Berlin
    #> tzcode source: internal
    #> 
    #> attached base packages:
    #> [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    #> [8] base     
    #> 
    #> other attached packages:
    #>  [1] topGO_2.65.0                SparseM_1.84-2             
    #>  [3] GO.db_3.23.1                graph_1.91.0               
    #>  [5] mosdef_1.9.0                clusterProfiler_4.21.0     
    #>  [7] org.Hs.eg.db_3.23.1         AnnotationDbi_1.75.0       
    #>  [9] DESeq2_1.51.7               SummarizedExperiment_1.43.0
    #> [11] Biobase_2.73.1              MatrixGenerics_1.25.0      
    #> [13] matrixStats_1.5.0           GenomicRanges_1.65.0       
    #> [15] Seqinfo_1.3.0               IRanges_2.45.0             
    #> [17] S4Vectors_0.51.1            BiocGenerics_0.59.0        
    #> [19] generics_0.1.4              macrophage_1.29.0          
    #> [21] EMMA_0.3.0                  BiocStyle_2.41.0           
    #> 
    #> loaded via a namespace (and not attached):
    #>   [1] splines_4.6.0            BiocIO_1.23.3            filelock_1.0.3          
    #>   [4] bitops_1.0-9             ggplotify_0.1.3          BiasedUrn_2.0.12        
    #>   [7] tibble_3.3.1             polyclip_1.10-7          enrichit_0.1.4          
    #>  [10] XML_3.99-0.23            lifecycle_1.0.5          httr2_1.2.2             
    #>  [13] processx_3.9.0           lattice_0.22-9           MASS_7.3-65             
    #>  [16] magrittr_2.0.5           sass_0.4.10              rmarkdown_2.31          
    #>  [19] jquerylib_0.1.4          yaml_2.3.12              otel_0.2.0              
    #>  [22] ggtangle_0.1.2           DBI_1.3.0                RColorBrewer_1.1-3      
    #>  [25] abind_1.4-8              purrr_1.2.2              RCurl_1.98-1.18         
    #>  [28] yulab.utils_0.2.4        tweenr_2.0.3             rappdirs_0.3.4          
    #>  [31] aisdk_1.1.0              gdtools_0.5.0            enrichplot_1.33.0       
    #>  [34] ggrepel_0.9.8            tidytree_0.4.7           pkgdown_2.2.0           
    #>  [37] codetools_0.2-20         DelayedArray_0.39.1      DOSE_4.7.0              
    #>  [40] DT_0.34.0                ggforce_0.5.0            tidyselect_1.2.1        
    #>  [43] aplot_0.2.9              UCSC.utils_1.9.0         farver_2.1.2            
    #>  [46] goseq_1.65.0             BiocFileCache_3.3.0      GenomicAlignments_1.49.0
    #>  [49] jsonlite_2.0.0           systemfonts_1.3.2        bbmle_1.0.25.1          
    #>  [52] progress_1.2.3           tools_4.6.0              ggnewscale_0.5.2        
    #>  [55] treeio_1.37.0            ragg_1.5.2               Rcpp_1.1.1-1.1          
    #>  [58] glue_1.8.1               SparseArray_1.11.13      BiocBaseUtils_1.15.0    
    #>  [61] mgcv_1.9-4               xfun_0.57                geneLenDataBase_1.49.0  
    #>  [64] qvalue_2.45.0            GenomeInfoDb_1.49.0      dplyr_1.2.1             
    #>  [67] numDeriv_2016.8-1.1      withr_3.0.2              BiocManager_1.30.27     
    #>  [70] fastmap_1.2.0            callr_3.7.6              digest_0.6.39           
    #>  [73] R6_2.6.1                 gridGraphics_0.5-1       textshaping_1.0.5       
    #>  [76] dichromat_2.0-0.1        biomaRt_2.69.0           RSQLite_3.52.0          
    #>  [79] cigarillo_1.3.0          tidyr_1.3.2              fontLiberation_0.1.0    
    #>  [82] rtracklayer_1.73.0       prettyunits_1.2.0        httr_1.4.8              
    #>  [85] htmlwidgets_1.6.4        S4Arrays_1.13.0          scatterpie_0.2.6        
    #>  [88] pkgconfig_2.0.3          gtable_0.3.6             blob_1.3.0              
    #>  [91] S7_0.2.2                 XVector_0.53.0           htmltools_0.5.9         
    #>  [94] fontBitstreamVera_0.1.1  bookdown_0.46            scales_1.4.0            
    #>  [97] png_0.1-9                ggfun_0.2.0              knitr_1.51              
    #> [100] rstudioapi_0.18.0        reshape2_1.4.5           rjson_0.2.23            
    #> [103] coda_0.19-4.1            nlme_3.1-169             curl_7.1.0              
    #> [106] bdsmatrix_1.3-7          cachem_1.1.0             stringr_1.6.0           
    #> [109] parallel_4.6.0           restfulr_0.0.16          desc_1.4.3              
    #> [112] apeglm_1.35.0            pillar_1.11.1            grid_4.6.0              
    #> [115] vctrs_0.7.3              tidydr_0.0.6             dbplyr_2.5.2            
    #> [118] cluster_2.1.8.2          evaluate_1.0.5           GenomicFeatures_1.65.0  
    #> [121] mvtnorm_1.3-7            cli_3.6.6                locfit_1.5-9.12         
    #> [124] compiler_4.6.0           Rsamtools_2.29.0         rlang_1.2.0             
    #> [127] crayon_1.5.3             emdbook_1.3.14           plyr_1.8.9              
    #> [130] fs_2.1.0                 ggiraph_0.9.6            stringi_1.8.7           
    #> [133] BiocParallel_1.47.0      txdbmaker_1.9.0          Biostrings_2.81.1       
    #> [136] lazyeval_0.2.3           GOSemSim_2.39.0          fontquiver_0.2.1        
    #> [139] Matrix_1.7-5             hms_1.1.4                patchwork_1.3.2         
    #> [142] bit64_4.8.0              ggplot2_4.0.3            KEGGREST_1.53.0         
    #> [145] igraph_2.3.1             memoise_2.0.1            bslib_0.10.0            
    #> [148] ggtree_4.3.0             bit_4.6.0                ape_5.8-1               
    #> [151] gson_0.1.0              
    #> 
    #> $extra
    #> list()
    #> 
    #> $emma_version
    #> [1] "0.3.0"

`EMMA` structures the `EMMA_record` attribute (i.e. the recorded
provenance information) into a list of elements:

``` bash
├── EMMA_record
│   ├── method         # how the analysis was performed
│   │   ├── call
│   │   ├── function_name
│   │   ├── package_name
│   │   ├── package_version
│   │   ├── wrapped_function
│   │   ├── wrapped_package
│   │   └── wrapper
│   ├── input         # inputs used for the analysis
│   │   └── arguments
│   ├── annotation    # annotation context
│   │   ├── organism
│   │   ├── gene_set_db
│   │   └── gene_set_db_version
│   ├── timestamp     # when the analysis was run
│   ├── session_info  # R session information
│   ├── extra         # user-defined additions
│   └── emma_version
```

``` r

# get the method record
emma_record$method
```

    #> $call
    #> enrichGO(gene = rownames(de_res), keyType = "ENSEMBL", OrgDb = org.Hs.eg.db, 
    #>     ont = "BP", pAdjustMethod = "BH", pvalueCutoff = 0.05, qvalueCutoff = 0.1)
    #> 
    #> $function_name
    #> [1] "enrichGO"
    #> 
    #> $package_name
    #> [1] "clusterProfiler"
    #> 
    #> $package_version
    #> [1] "4.21.0"
    #> 
    #> $wrapped_function
    #> NULL
    #> 
    #> $wrapped_package
    #> NULL
    #> 
    #> $wrapper
    #> [1] FALSE

With [`EMMA_run()`](../reference/EMMA_run.md), we can decide whether we
want to save the value of arguments used in our call or not. This can be
useful, for example, to avoid unnecessarily increasing the size of the
result object. For this, we can use the argument `args_form`:

``` r

fea_res_no_param <- enrichGO(gene = rownames(de_res),
                             universe = gene_universe,
                             keyType = "ENSEMBL",
                             OrgDb = org.Hs.eg.db,
                             ont = "BP",
                             pAdjustMethod = "BH",
                             pvalueCutoff = 0.05,
                             qvalueCutoff = 0.1,
                             readable = TRUE) |> 
  EMMA_run(args_form = "unevaluated") # when we don't want the values stored
                                      # else set to evaluated (default)

# check
EMMA_get_record(fea_res_no_param)
```

    #> $method
    #> $method$call
    #> enrichGO(gene = rownames(de_res), universe = gene_universe, keyType = "ENSEMBL", 
    #>     OrgDb = org.Hs.eg.db, ont = "BP", pAdjustMethod = "BH", pvalueCutoff = 0.05, 
    #>     qvalueCutoff = 0.1, readable = TRUE)
    #> 
    #> $method$function_name
    #> [1] "enrichGO"
    #> 
    #> $method$package_name
    #> [1] "clusterProfiler"
    #> 
    #> $method$package_version
    #> [1] "4.21.0"
    #> 
    #> $method$wrapped_function
    #> NULL
    #> 
    #> $method$wrapped_package
    #> NULL
    #> 
    #> $method$wrapper
    #> [1] FALSE
    #> 
    #> 
    #> $input
    #> $input$arguments
    #> $input$arguments$gene
    #> rownames(de_res)
    #> 
    #> $input$arguments$universe
    #> gene_universe
    #> 
    #> $input$arguments$keyType
    #> [1] "ENSEMBL"
    #> 
    #> $input$arguments$OrgDb
    #> org.Hs.eg.db
    #> 
    #> $input$arguments$ont
    #> [1] "BP"
    #> 
    #> $input$arguments$pAdjustMethod
    #> [1] "BH"
    #> 
    #> $input$arguments$pvalueCutoff
    #> [1] 0.05
    #> 
    #> $input$arguments$qvalueCutoff
    #> [1] 0.1
    #> 
    #> $input$arguments$readable
    #> [1] TRUE
    #> 
    #> 
    #> 
    #> $annotation
    #> $annotation$organism
    #> [1] "Homo sapiens"
    #> 
    #> $annotation$gene_set_db
    #> [1] "GO"
    #> 
    #> $annotation$gene_set_db_version
    #> [1] "3.23.1"
    #> 
    #> 
    #> $timestamp
    #> [1] "2026-05-11 19:17:38 CEST"
    #> 
    #> $session_info
    #> R version 4.6.0 (2026-04-24)
    #> Platform: aarch64-apple-darwin23
    #> Running under: macOS Sequoia 15.7.2
    #> 
    #> Matrix products: default
    #> BLAS:   /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRblas.0.dylib 
    #> LAPACK: /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
    #> 
    #> locale:
    #> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    #> 
    #> time zone: Europe/Berlin
    #> tzcode source: internal
    #> 
    #> attached base packages:
    #> [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    #> [8] base     
    #> 
    #> other attached packages:
    #>  [1] topGO_2.65.0                SparseM_1.84-2             
    #>  [3] GO.db_3.23.1                graph_1.91.0               
    #>  [5] mosdef_1.9.0                clusterProfiler_4.21.0     
    #>  [7] org.Hs.eg.db_3.23.1         AnnotationDbi_1.75.0       
    #>  [9] DESeq2_1.51.7               SummarizedExperiment_1.43.0
    #> [11] Biobase_2.73.1              MatrixGenerics_1.25.0      
    #> [13] matrixStats_1.5.0           GenomicRanges_1.65.0       
    #> [15] Seqinfo_1.3.0               IRanges_2.45.0             
    #> [17] S4Vectors_0.51.1            BiocGenerics_0.59.0        
    #> [19] generics_0.1.4              macrophage_1.29.0          
    #> [21] EMMA_0.3.0                  BiocStyle_2.41.0           
    #> 
    #> loaded via a namespace (and not attached):
    #>   [1] splines_4.6.0            BiocIO_1.23.3            filelock_1.0.3          
    #>   [4] bitops_1.0-9             ggplotify_0.1.3          BiasedUrn_2.0.12        
    #>   [7] tibble_3.3.1             polyclip_1.10-7          enrichit_0.1.4          
    #>  [10] XML_3.99-0.23            lifecycle_1.0.5          httr2_1.2.2             
    #>  [13] processx_3.9.0           lattice_0.22-9           MASS_7.3-65             
    #>  [16] magrittr_2.0.5           sass_0.4.10              rmarkdown_2.31          
    #>  [19] jquerylib_0.1.4          yaml_2.3.12              otel_0.2.0              
    #>  [22] ggtangle_0.1.2           DBI_1.3.0                RColorBrewer_1.1-3      
    #>  [25] abind_1.4-8              purrr_1.2.2              RCurl_1.98-1.18         
    #>  [28] yulab.utils_0.2.4        tweenr_2.0.3             rappdirs_0.3.4          
    #>  [31] aisdk_1.1.0              gdtools_0.5.0            enrichplot_1.33.0       
    #>  [34] ggrepel_0.9.8            tidytree_0.4.7           pkgdown_2.2.0           
    #>  [37] codetools_0.2-20         DelayedArray_0.39.1      DOSE_4.7.0              
    #>  [40] DT_0.34.0                ggforce_0.5.0            tidyselect_1.2.1        
    #>  [43] aplot_0.2.9              UCSC.utils_1.9.0         farver_2.1.2            
    #>  [46] goseq_1.65.0             BiocFileCache_3.3.0      GenomicAlignments_1.49.0
    #>  [49] jsonlite_2.0.0           systemfonts_1.3.2        bbmle_1.0.25.1          
    #>  [52] progress_1.2.3           tools_4.6.0              ggnewscale_0.5.2        
    #>  [55] treeio_1.37.0            ragg_1.5.2               Rcpp_1.1.1-1.1          
    #>  [58] glue_1.8.1               SparseArray_1.11.13      BiocBaseUtils_1.15.0    
    #>  [61] mgcv_1.9-4               xfun_0.57                geneLenDataBase_1.49.0  
    #>  [64] qvalue_2.45.0            GenomeInfoDb_1.49.0      dplyr_1.2.1             
    #>  [67] numDeriv_2016.8-1.1      withr_3.0.2              BiocManager_1.30.27     
    #>  [70] fastmap_1.2.0            callr_3.7.6              digest_0.6.39           
    #>  [73] R6_2.6.1                 gridGraphics_0.5-1       textshaping_1.0.5       
    #>  [76] dichromat_2.0-0.1        biomaRt_2.69.0           RSQLite_3.52.0          
    #>  [79] cigarillo_1.3.0          tidyr_1.3.2              fontLiberation_0.1.0    
    #>  [82] rtracklayer_1.73.0       prettyunits_1.2.0        httr_1.4.8              
    #>  [85] htmlwidgets_1.6.4        S4Arrays_1.13.0          scatterpie_0.2.6        
    #>  [88] pkgconfig_2.0.3          gtable_0.3.6             blob_1.3.0              
    #>  [91] S7_0.2.2                 XVector_0.53.0           htmltools_0.5.9         
    #>  [94] fontBitstreamVera_0.1.1  bookdown_0.46            scales_1.4.0            
    #>  [97] png_0.1-9                ggfun_0.2.0              knitr_1.51              
    #> [100] rstudioapi_0.18.0        reshape2_1.4.5           rjson_0.2.23            
    #> [103] coda_0.19-4.1            nlme_3.1-169             curl_7.1.0              
    #> [106] bdsmatrix_1.3-7          cachem_1.1.0             stringr_1.6.0           
    #> [109] parallel_4.6.0           restfulr_0.0.16          desc_1.4.3              
    #> [112] apeglm_1.35.0            pillar_1.11.1            grid_4.6.0              
    #> [115] vctrs_0.7.3              tidydr_0.0.6             dbplyr_2.5.2            
    #> [118] cluster_2.1.8.2          evaluate_1.0.5           GenomicFeatures_1.65.0  
    #> [121] mvtnorm_1.3-7            cli_3.6.6                locfit_1.5-9.12         
    #> [124] compiler_4.6.0           Rsamtools_2.29.0         rlang_1.2.0             
    #> [127] crayon_1.5.3             emdbook_1.3.14           plyr_1.8.9              
    #> [130] fs_2.1.0                 ggiraph_0.9.6            stringi_1.8.7           
    #> [133] BiocParallel_1.47.0      txdbmaker_1.9.0          Biostrings_2.81.1       
    #> [136] lazyeval_0.2.3           GOSemSim_2.39.0          fontquiver_0.2.1        
    #> [139] Matrix_1.7-5             hms_1.1.4                patchwork_1.3.2         
    #> [142] bit64_4.8.0              ggplot2_4.0.3            KEGGREST_1.53.0         
    #> [145] igraph_2.3.1             memoise_2.0.1            bslib_0.10.0            
    #> [148] ggtree_4.3.0             bit_4.6.0                ape_5.8-1               
    #> [151] gson_0.1.0              
    #> 
    #> $extra
    #> list()
    #> 
    #> $emma_version
    #> [1] "0.3.0"

We can also choose whether to save the R session information with the
record using the argument `store_session_info`, which defaults to
`TRUE`.

#### `EMMA_explain()`: Summarizing recorded information into text

[`EMMA_explain()`](../reference/EMMA_explain.md) generates a
human-readable description of the FEA, similar to a Materials and
Methods section of a paper, by summarizing the executed call, the
parameters, software context, and reference databases used.

``` r

EMMA_explain(fea_res, get_citation = TRUE)
```

    #> ℹ You can always complete your text with additional information from `getEMMARecord()`!

    #> ℹ References:

    #> Please cite S. Xu (2024) for using clusterProfiler. In addition, please
    #> cite G. Yu (2010) when using GOSemSim, G. Yu (2015) when using DOSE and
    #> G. Yu (2015) when using ChIPseeker.
    #>   G Yu. Thirteen years of clusterProfiler. The Innovation. 2024,
    #>   5(6):100722
    #>   S Xu, E Hu, Y Cai, Z Xie, X Luo, L Zhan, W Tang, Q Wang, B Liu, R
    #>   Wang, W Xie, T Wu, L Xie, G Yu. Using clusterProfiler to characterize
    #>   multiomics data. Nature Protocols. 2024, 19(11):3292-3320
    #>   T Wu, E Hu, S Xu, M Chen, P Guo, Z Dai, T Feng, L Zhou, W Tang, L
    #>   Zhan, X Fu, S Liu, X Bo, and G Yu. clusterProfiler 4.0: A universal
    #>   enrichment tool for interpreting omics data. The Innovation. 2021,
    #>   2(3):100141
    #>   Guangchuang Yu, Li-Gen Wang, Yanyan Han and Qing-Yu He.
    #>   clusterProfiler: an R package for comparing biological themes among
    #>   gene clusters. OMICS: A Journal of Integrative Biology 2012,
    #>   16(5):284-287
    #> To see these entries in BibTeX format, use 'format(<citation>,
    #> bibtex=TRUE)', or 'toBibtex(.)'.

\[1\] “Functional Enrichment Analysis was performed using the enrichGO()
function from the clusterProfiler package (version 4.21.0) with the GO
database (version 3.23.1). No custom background gene set was recorded.
Multiple testing correction was performed using the BH method.”

### `EMMA` with custom/wrapper functions

You can also use a custom function that you developed, or a wrapper
function (from packages such as
*[mosdef](https://bioconductor.org/packages/3.24/mosdef)*). In this
case, [`EMMA_run()`](../reference/EMMA_run.md) will attempt to capture
as much metadata as possible:

``` r

mosdef_fea_res <- mosdef::run_goseq(de_genes = rownames(de_res),
                             bg_genes = gene_universe,
                             mapping = "org.Hs.eg.db",
                             id = "ensGene",
                             genome = "hg19") |> 
  EMMA_run(store_session_info = FALSE,
           args_form = "unevaluated")

# quick inspection
EMMA_get_record(mosdef_fea_res)
```

    #> $method
    #> $method$call
    #> mosdef::run_goseq(de_genes = rownames(de_res), bg_genes = gene_universe, 
    #>     mapping = "org.Hs.eg.db", id = "ensGene", genome = "hg19")
    #> 
    #> $method$function_name
    #> [1] "run_goseq"
    #> 
    #> $method$package_name
    #> [1] "mosdef"
    #> 
    #> $method$package_version
    #> [1] "1.9.0"
    #> 
    #> $method$wrapped_function
    #> [1] "goseq"
    #> 
    #> $method$wrapped_package
    #> [1] "goseq"
    #> 
    #> $method$wrapper
    #> [1] TRUE
    #> 
    #> 
    #> $input
    #> $input$arguments
    #> $input$arguments$de_genes
    #> rownames(de_res)
    #> 
    #> $input$arguments$bg_genes
    #> gene_universe
    #> 
    #> $input$arguments$mapping
    #> [1] "org.Hs.eg.db"
    #> 
    #> $input$arguments$id
    #> [1] "ensGene"
    #> 
    #> $input$arguments$genome
    #> [1] "hg19"
    #> 
    #> 
    #> 
    #> $annotation
    #> $annotation$organism
    #> [1] "Homo sapiens"
    #> 
    #> $annotation$gene_set_db
    #> [1] "GO"
    #> 
    #> $annotation$gene_set_db_version
    #> [1] "3.23.1"
    #> 
    #> 
    #> $timestamp
    #> [1] "2026-05-11 19:17:48 CEST"
    #> 
    #> $session_info
    #> NULL
    #> 
    #> $extra
    #> list()
    #> 
    #> $emma_version
    #> [1] "0.3.0"

``` r

# a custom function (not from a package)
my_custom_function <- function(gene, universe = NULL,
                               ontology = "BP", id_type = "ENTREZID",
                               org_db_name = "org.Hs.eg.db", 
                               organism = "hsapiens") {
  # a wrapper of a wrapper :D
  res1 <- mosdef::run_topGO(de_genes = gene,
                            bg_genes = gene_universe,
                            ontology = ontology,
                            gene_id = id_type,
                            mapping = org_db_name,
                            add_gene_to_terms = TRUE)

  res2 <- gprofiler2::gost(query = gene,
                           organism = organism,
                           custom_bg = gene_universe)

  return(list(topGO_res = res1,
              gost_res = res2
  ))
}

# run analysis with EMMA
frankenstein_fea <- my_custom_function(
  gene = rownames(de_res),
  universe = gene_universe,
  ontology = "BP",
  id_type = "ENSEMBL",
  org_db_name = "org.Hs.eg.db",
  organism = "hsapiens"
  ) |> EMMA_run(store_session_info = FALSE,
                args_form = "unevaluated") 

# quick inspection
EMMA_get_record(frankenstein_fea)
```

    #> $method
    #> $method$call
    #> my_custom_function(gene = rownames(de_res), universe = gene_universe, 
    #>     ontology = "BP", id_type = "ENSEMBL", org_db_name = "org.Hs.eg.db", 
    #>     organism = "hsapiens")
    #> 
    #> $method$function_name
    #> [1] "my_custom_function"
    #> 
    #> $method$package_name
    #> [1] NA
    #> 
    #> $method$package_version
    #> [1] NA
    #> 
    #> $method$wrapped_function
    #> [1] "run_topGO" "gost"     
    #> 
    #> $method$wrapped_package
    #> [1] "mosdef"     "gprofiler2"
    #> 
    #> $method$wrapper
    #> [1] TRUE
    #> 
    #> 
    #> $input
    #> $input$arguments
    #> $input$arguments$gene
    #> rownames(de_res)
    #> 
    #> $input$arguments$universe
    #> gene_universe
    #> 
    #> $input$arguments$ontology
    #> [1] "BP"
    #> 
    #> $input$arguments$id_type
    #> [1] "ENSEMBL"
    #> 
    #> $input$arguments$org_db_name
    #> [1] "org.Hs.eg.db"
    #> 
    #> $input$arguments$organism
    #> [1] "hsapiens"
    #> 
    #> 
    #> 
    #> $annotation
    #> $annotation$organism
    #> [1] "hsapiens"
    #> 
    #> $annotation$gene_set_db
    #>  [1] "CORUM" "GO:BP" "GO:CC" "GO:MF" "HP"    "HPA"   "KEGG"  "MIRNA" "REAC" 
    #> [10] "TF"    "WP"   
    #> 
    #> $annotation$gene_set_db_version
    #> [1] "28.11.2022 Corum 4.1"                                         
    #> [2] "annotations: BioMart\nclasses: releases/2026-01-23"           
    #> [3] "annotations: 03.2026\nclasses: None"                          
    #> [4] "annotations: HPA website: 25-11-06\nclasses: script: 26-01-20"
    #> [5] "KEGG FTP Release 2026-03-15"                                  
    #> [6] "Release 10.0"                                                 
    #> [7] "annotations: BioMart\nclasses: 2026-3-20"                     
    #> [8] "annotations: TRANSFAC Release 2025.2\nclasses: v2"            
    #> [9] "20260310"                                                     
    #> 
    #> 
    #> $timestamp
    #> [1] "2026-05-11 19:18:01 CEST"
    #> 
    #> $session_info
    #> NULL
    #> 
    #> $extra
    #> list()
    #> 
    #> $emma_version
    #> [1] "0.3.0"

## `EMMA_add_custom_metadata()`: Adding extra information

The user can always attach extra metadata that `EMMA` might not be able
to capture automatically. To keep everything organized, we can use
[`EMMA_add_custom_metadata()`](../reference/EMMA_add_custom_metadata.md)
function

``` r

frankenstein_fea2 <- EMMA_add_custom_metadata(res = frankenstein_fea,
                                             extra = list(
                                               wrapped_function_topGO = "runTest",
                                               notes = "any other meaningful info"))

EMMA_get_record(frankenstein_fea2)$extra
```

    #> $wrapped_function_topGO
    #> [1] "runTest"
    #> 
    #> $notes
    #> [1] "any other meaningful info"

Since the `EMMA_record` is attached as attribute to the original results
objects, it can be preserved when integrating results into structured
containers such as `DeeDeeExperiment`. This enables both FEA results and
their associated provenance information to be stored and managed
together, facilitating reproducibility, organization, and sharing of
complex omics analyses.

``` r

dde <- DeeDeeExperiment::DeeDeeExperiment(sce = dds_macrophage,
                                          de_results = IFNg_vs_naive,
                                          enrich_results =  list(
                                            IFNg_vs_naive = fea_res_no_param))

fea <- DeeDeeExperiment::getFEA(dde, format = "original")

EMMA_get_record(fea)
```

    #> $method
    #> $method$call
    #> enrichGO(gene = rownames(de_res), universe = gene_universe, keyType = "ENSEMBL", 
    #>     OrgDb = org.Hs.eg.db, ont = "BP", pAdjustMethod = "BH", pvalueCutoff = 0.05, 
    #>     qvalueCutoff = 0.1, readable = TRUE)
    #> 
    #> $method$function_name
    #> [1] "enrichGO"
    #> 
    #> $method$package_name
    #> [1] "clusterProfiler"
    #> 
    #> $method$package_version
    #> [1] "4.21.0"
    #> 
    #> $method$wrapped_function
    #> NULL
    #> 
    #> $method$wrapped_package
    #> NULL
    #> 
    #> $method$wrapper
    #> [1] FALSE
    #> 
    #> 
    #> $input
    #> $input$arguments
    #> $input$arguments$gene
    #> rownames(de_res)
    #> 
    #> $input$arguments$universe
    #> gene_universe
    #> 
    #> $input$arguments$keyType
    #> [1] "ENSEMBL"
    #> 
    #> $input$arguments$OrgDb
    #> org.Hs.eg.db
    #> 
    #> $input$arguments$ont
    #> [1] "BP"
    #> 
    #> $input$arguments$pAdjustMethod
    #> [1] "BH"
    #> 
    #> $input$arguments$pvalueCutoff
    #> [1] 0.05
    #> 
    #> $input$arguments$qvalueCutoff
    #> [1] 0.1
    #> 
    #> $input$arguments$readable
    #> [1] TRUE
    #> 
    #> 
    #> 
    #> $annotation
    #> $annotation$organism
    #> [1] "Homo sapiens"
    #> 
    #> $annotation$gene_set_db
    #> [1] "GO"
    #> 
    #> $annotation$gene_set_db_version
    #> [1] "3.23.1"
    #> 
    #> 
    #> $timestamp
    #> [1] "2026-05-11 19:17:38 CEST"
    #> 
    #> $session_info
    #> R version 4.6.0 (2026-04-24)
    #> Platform: aarch64-apple-darwin23
    #> Running under: macOS Sequoia 15.7.2
    #> 
    #> Matrix products: default
    #> BLAS:   /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRblas.0.dylib 
    #> LAPACK: /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
    #> 
    #> locale:
    #> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    #> 
    #> time zone: Europe/Berlin
    #> tzcode source: internal
    #> 
    #> attached base packages:
    #> [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    #> [8] base     
    #> 
    #> other attached packages:
    #>  [1] topGO_2.65.0                SparseM_1.84-2             
    #>  [3] GO.db_3.23.1                graph_1.91.0               
    #>  [5] mosdef_1.9.0                clusterProfiler_4.21.0     
    #>  [7] org.Hs.eg.db_3.23.1         AnnotationDbi_1.75.0       
    #>  [9] DESeq2_1.51.7               SummarizedExperiment_1.43.0
    #> [11] Biobase_2.73.1              MatrixGenerics_1.25.0      
    #> [13] matrixStats_1.5.0           GenomicRanges_1.65.0       
    #> [15] Seqinfo_1.3.0               IRanges_2.45.0             
    #> [17] S4Vectors_0.51.1            BiocGenerics_0.59.0        
    #> [19] generics_0.1.4              macrophage_1.29.0          
    #> [21] EMMA_0.3.0                  BiocStyle_2.41.0           
    #> 
    #> loaded via a namespace (and not attached):
    #>   [1] splines_4.6.0            BiocIO_1.23.3            filelock_1.0.3          
    #>   [4] bitops_1.0-9             ggplotify_0.1.3          BiasedUrn_2.0.12        
    #>   [7] tibble_3.3.1             polyclip_1.10-7          enrichit_0.1.4          
    #>  [10] XML_3.99-0.23            lifecycle_1.0.5          httr2_1.2.2             
    #>  [13] processx_3.9.0           lattice_0.22-9           MASS_7.3-65             
    #>  [16] magrittr_2.0.5           sass_0.4.10              rmarkdown_2.31          
    #>  [19] jquerylib_0.1.4          yaml_2.3.12              otel_0.2.0              
    #>  [22] ggtangle_0.1.2           DBI_1.3.0                RColorBrewer_1.1-3      
    #>  [25] abind_1.4-8              purrr_1.2.2              RCurl_1.98-1.18         
    #>  [28] yulab.utils_0.2.4        tweenr_2.0.3             rappdirs_0.3.4          
    #>  [31] aisdk_1.1.0              gdtools_0.5.0            enrichplot_1.33.0       
    #>  [34] ggrepel_0.9.8            tidytree_0.4.7           pkgdown_2.2.0           
    #>  [37] codetools_0.2-20         DelayedArray_0.39.1      DOSE_4.7.0              
    #>  [40] DT_0.34.0                ggforce_0.5.0            tidyselect_1.2.1        
    #>  [43] aplot_0.2.9              UCSC.utils_1.9.0         farver_2.1.2            
    #>  [46] goseq_1.65.0             BiocFileCache_3.3.0      GenomicAlignments_1.49.0
    #>  [49] jsonlite_2.0.0           systemfonts_1.3.2        bbmle_1.0.25.1          
    #>  [52] progress_1.2.3           tools_4.6.0              ggnewscale_0.5.2        
    #>  [55] treeio_1.37.0            ragg_1.5.2               Rcpp_1.1.1-1.1          
    #>  [58] glue_1.8.1               SparseArray_1.11.13      BiocBaseUtils_1.15.0    
    #>  [61] mgcv_1.9-4               xfun_0.57                geneLenDataBase_1.49.0  
    #>  [64] qvalue_2.45.0            GenomeInfoDb_1.49.0      dplyr_1.2.1             
    #>  [67] numDeriv_2016.8-1.1      withr_3.0.2              BiocManager_1.30.27     
    #>  [70] fastmap_1.2.0            callr_3.7.6              digest_0.6.39           
    #>  [73] R6_2.6.1                 gridGraphics_0.5-1       textshaping_1.0.5       
    #>  [76] dichromat_2.0-0.1        biomaRt_2.69.0           RSQLite_3.52.0          
    #>  [79] cigarillo_1.3.0          tidyr_1.3.2              fontLiberation_0.1.0    
    #>  [82] rtracklayer_1.73.0       prettyunits_1.2.0        httr_1.4.8              
    #>  [85] htmlwidgets_1.6.4        S4Arrays_1.13.0          scatterpie_0.2.6        
    #>  [88] pkgconfig_2.0.3          gtable_0.3.6             blob_1.3.0              
    #>  [91] S7_0.2.2                 XVector_0.53.0           htmltools_0.5.9         
    #>  [94] fontBitstreamVera_0.1.1  bookdown_0.46            scales_1.4.0            
    #>  [97] png_0.1-9                ggfun_0.2.0              knitr_1.51              
    #> [100] rstudioapi_0.18.0        reshape2_1.4.5           rjson_0.2.23            
    #> [103] coda_0.19-4.1            nlme_3.1-169             curl_7.1.0              
    #> [106] bdsmatrix_1.3-7          cachem_1.1.0             stringr_1.6.0           
    #> [109] parallel_4.6.0           restfulr_0.0.16          desc_1.4.3              
    #> [112] apeglm_1.35.0            pillar_1.11.1            grid_4.6.0              
    #> [115] vctrs_0.7.3              tidydr_0.0.6             dbplyr_2.5.2            
    #> [118] cluster_2.1.8.2          evaluate_1.0.5           GenomicFeatures_1.65.0  
    #> [121] mvtnorm_1.3-7            cli_3.6.6                locfit_1.5-9.12         
    #> [124] compiler_4.6.0           Rsamtools_2.29.0         rlang_1.2.0             
    #> [127] crayon_1.5.3             emdbook_1.3.14           plyr_1.8.9              
    #> [130] fs_2.1.0                 ggiraph_0.9.6            stringi_1.8.7           
    #> [133] BiocParallel_1.47.0      txdbmaker_1.9.0          Biostrings_2.81.1       
    #> [136] lazyeval_0.2.3           GOSemSim_2.39.0          fontquiver_0.2.1        
    #> [139] Matrix_1.7-5             hms_1.1.4                patchwork_1.3.2         
    #> [142] bit64_4.8.0              ggplot2_4.0.3            KEGGREST_1.53.0         
    #> [145] igraph_2.3.1             memoise_2.0.1            bslib_0.10.0            
    #> [148] ggtree_4.3.0             bit_4.6.0                ape_5.8-1               
    #> [151] gson_0.1.0              
    #> 
    #> $extra
    #> list()
    #> 
    #> $emma_version
    #> [1] "0.3.0"

## `EMMA_freeze()`: Recording the Analysis Environment

[`EMMA_freeze()`](../reference/EMMA_freeze.md) records the R environment
at the time of analysis by generating a lockfile using `renv`. By
default, the snapshot is created with `force = TRUE`, allowing the
environment to be recorded even when inconsistencies (e.g. version
mismatches) are present.

This behavior reflects the goal of preserving the analysis environment
as it was used in practice, rather than attempting to enforce a fully
consistent state.

``` r

if (requireNamespace("renv", quietly = TRUE)) {
   project_path <- tempfile("my_project_with_emma")
   dir.create(project_path)
EMMA_freeze(project = project_path,
            file = "analysis.lock",
            pkgs = loadedNamespaces(),
            prompt = FALSE,
            force = TRUE)
}
```

    #> The following Bioconductor packages appear to be from a separate Bioconductor release:
    #> - EMMA        [installed 0.3.0   != latest <NA>]
    #> - edgeR       [installed 4.9.9   != latest 4.11.0]
    #> - SparseArray [installed 1.11.13 != latest 1.13.2]
    #> - DESeq2      [installed 1.51.7  != latest 1.53.0]
    #> - IRanges     [installed 2.45.0  != latest 2.47.0]
    #> renv may be unable to restore these packages.
    #> Bioconductor version: 3.24
    #> 
    #> The following package(s) will be updated in the lockfile:
    #> 
    #> # Bioconductor ---------------------------------------------------------------
    #> - EMMA                   [* -> 0.3.0]
    #> - GO.db                  [* -> 3.23.1]
    #> - org.Hs.eg.db           [* -> 3.23.1]
    #> 
    #> # Bioconductor 3.23 ----------------------------------------------------------
    #> - edgeR                  [* -> 4.9.9]
    #> - SparseArray            [* -> 1.11.13]
    #> 
    #> # Bioconductor 3.24 ----------------------------------------------------------
    #> - AnnotationDbi          [* -> 1.75.0]
    #> - apeglm                 [* -> 1.35.0]
    #> - Biobase                [* -> 2.73.1]
    #> - BiocBaseUtils          [* -> 1.15.0]
    #> - BiocFileCache          [* -> 3.3.0]
    #> - BiocGenerics           [* -> 0.59.0]
    #> - BiocIO                 [* -> 1.23.3]
    #> - BiocParallel           [* -> 1.47.0]
    #> - BiocStyle              [* -> 2.41.0]
    #> - BiocVersion            [* -> 3.24.0]
    #> - biomaRt                [* -> 2.69.0]
    #> - Biostrings             [* -> 2.81.1]
    #> - cigarillo              [* -> 1.3.0]
    #> - clusterProfiler        [* -> 4.21.0]
    #> - DeeDeeExperiment       [* -> 1.3.0]
    #> - DelayedArray           [* -> 0.39.1]
    #> - DOSE                   [* -> 4.7.0]
    #> - enrichplot             [* -> 1.33.0]
    #> - geneLenDataBase        [* -> 1.49.0]
    #> - GenomeInfoDb           [* -> 1.49.0]
    #> - GenomicAlignments      [* -> 1.49.0]
    #> - GenomicFeatures        [* -> 1.65.0]
    #> - GenomicRanges          [* -> 1.65.0]
    #> - ggtree                 [* -> 4.3.0]
    #> - GOSemSim               [* -> 2.39.0]
    #> - goseq                  [* -> 1.65.0]
    #> - graph                  [* -> 1.91.0]
    #> - KEGGREST               [* -> 1.53.0]
    #> - limma                  [* -> 3.69.0]
    #> - macrophage             [* -> 1.29.0]
    #> - MatrixGenerics         [* -> 1.25.0]
    #> - mosdef                 [* -> 1.9.0]
    #> - qvalue                 [* -> 2.45.0]
    #> - Rhtslib                [* -> 3.9.0]
    #> - Rsamtools              [* -> 2.29.0]
    #> - rtracklayer            [* -> 1.73.0]
    #> - S4Arrays               [* -> 1.13.0]
    #> - S4Vectors              [* -> 0.51.1]
    #> - Seqinfo                [* -> 1.3.0]
    #> - SingleCellExperiment   [* -> 1.35.0]
    #> - SummarizedExperiment   [* -> 1.43.0]
    #> - topGO                  [* -> 2.65.0]
    #> - treeio                 [* -> 1.37.0]
    #> - txdbmaker              [* -> 1.9.0]
    #> - UCSC.utils             [* -> 1.9.0]
    #> - XVector                [* -> 0.53.0]
    #> 
    #> # CRAN -----------------------------------------------------------------------
    #> - abind                  [* -> 1.4-8]
    #> - aisdk                  [* -> 1.1.0]
    #> - ape                    [* -> 5.8-1]
    #> - aplot                  [* -> 0.2.9]
    #> - askpass                [* -> 1.2.1]
    #> - base64enc              [* -> 0.1-6]
    #> - bbmle                  [* -> 1.0.25.1]
    #> - bdsmatrix              [* -> 1.3-7]
    #> - BH                     [* -> 1.90.0-1]
    #> - BiasedUrn              [* -> 2.0.12]
    #> - BiocManager            [* -> 1.30.27]
    #> - bit                    [* -> 4.6.0]
    #> - bit64                  [* -> 4.8.0]
    #> - bitops                 [* -> 1.0-9]
    #> - blob                   [* -> 1.3.0]
    #> - bookdown               [* -> 0.46]
    #> - brio                   [* -> 1.1.5]
    #> - bslib                  [* -> 0.10.0]
    #> - cachem                 [* -> 1.1.0]
    #> - callr                  [* -> 3.7.6]
    #> - cli                    [* -> 3.6.6]
    #> - cluster                [* -> 2.1.8.2]
    #> - coda                   [* -> 0.19-4.1]
    #> - codetools              [* -> 0.2-20]
    #> - cpp11                  [* -> 0.5.5]
    #> - crayon                 [* -> 1.5.3]
    #> - crosstalk              [* -> 1.2.2]
    #> - curl                   [* -> 7.1.0]
    #> - data.table             [* -> 1.18.4]
    #> - DBI                    [* -> 1.3.0]
    #> - dbplyr                 [* -> 2.5.2]
    #> - desc                   [* -> 1.4.3]
    #> - dichromat              [* -> 2.0-0.1]
    #> - digest                 [* -> 0.6.39]
    #> - downlit                [* -> 0.4.5]
    #> - dplyr                  [* -> 1.2.1]
    #> - DT                     [* -> 0.34.0]
    #> - emdbook                [* -> 1.3.14]
    #> - enrichit               [* -> 0.1.4]
    #> - evaluate               [* -> 1.0.5]
    #> - fansi                  [* -> 1.0.7]
    #> - farver                 [* -> 2.1.2]
    #> - fastmap                [* -> 1.2.0]
    #> - filelock               [* -> 1.0.3]
    #> - fontawesome            [* -> 0.5.3]
    #> - fontBitstreamVera      [* -> 0.1.1]
    #> - fontLiberation         [* -> 0.1.0]
    #> - fontquiver             [* -> 0.2.1]
    #> - formatR                [* -> 1.14]
    #> - fs                     [* -> 2.1.0]
    #> - futile.logger          [* -> 1.4.9]
    #> - futile.options         [* -> 1.0.1]
    #> - gdtools                [* -> 0.5.0]
    #> - generics               [* -> 0.1.4]
    #> - ggforce                [* -> 0.5.0]
    #> - ggfun                  [* -> 0.2.0]
    #> - ggiraph                [* -> 0.9.6]
    #> - ggnewscale             [* -> 0.5.2]
    #> - ggplot2                [* -> 4.0.3]
    #> - ggplotify              [* -> 0.1.3]
    #> - ggrepel                [* -> 0.9.8]
    #> - ggtangle               [* -> 0.1.2]
    #> - glue                   [* -> 1.8.1]
    #> - gprofiler2             [* -> 0.2.4]
    #> - gridExtra              [* -> 2.3]
    #> - gridGraphics           [* -> 0.5-1]
    #> - gson                   [* -> 0.1.0]
    #> - gtable                 [* -> 0.3.6]
    #> - highr                  [* -> 0.12]
    #> - hms                    [* -> 1.1.4]
    #> - htmltools              [* -> 0.5.9]
    #> - htmlwidgets            [* -> 1.6.4]
    #> - httr                   [* -> 1.4.8]
    #> - httr2                  [* -> 1.2.2]
    #> - igraph                 [* -> 2.3.1]
    #> - isoband                [* -> 0.3.0]
    #> - jquerylib              [* -> 0.1.4]
    #> - jsonlite               [* -> 2.0.0]
    #> - knitr                  [* -> 1.51]
    #> - labeling               [* -> 0.4.3]
    #> - lambda.r               [* -> 1.2.4]
    #> - later                  [* -> 1.4.8]
    #> - lattice                [* -> 0.22-9]
    #> - lazyeval               [* -> 0.2.3]
    #> - lifecycle              [* -> 1.0.5]
    #> - locfit                 [* -> 1.5-9.12]
    #> - magrittr               [* -> 2.0.5]
    #> - MASS                   [* -> 7.3-65]
    #> - Matrix                 [* -> 1.7-5]
    #> - matrixStats            [* -> 1.5.0]
    #> - memoise                [* -> 2.0.1]
    #> - mgcv                   [* -> 1.9-4]
    #> - mime                   [* -> 0.13]
    #> - mvtnorm                [* -> 1.3-7]
    #> - nlme                   [* -> 3.1-169]
    #> - numDeriv               [* -> 2016.8-1.1]
    #> - openssl                [* -> 2.4.0]
    #> - otel                   [* -> 0.2.0]
    #> - patchwork              [* -> 1.3.2]
    #> - pillar                 [* -> 1.11.1]
    #> - pkgconfig              [* -> 2.0.3]
    #> - pkgdown                [* -> 2.2.0]
    #> - plotly                 [* -> 4.12.0]
    #> - plyr                   [* -> 1.8.9]
    #> - png                    [* -> 0.1-9]
    #> - polyclip               [* -> 1.10-7]
    #> - prettyunits            [* -> 1.2.0]
    #> - processx               [* -> 3.9.0]
    #> - progress               [* -> 1.2.3]
    #> - promises               [* -> 1.5.0]
    #> - ps                     [* -> 1.9.3]
    #> - purrr                  [* -> 1.2.2]
    #> - R6                     [* -> 2.6.1]
    #> - ragg                   [* -> 1.5.2]
    #> - rappdirs               [* -> 0.3.4]
    #> - RColorBrewer           [* -> 1.1-3]
    #> - Rcpp                   [* -> 1.1.1-1.1]
    #> - RcppArmadillo          [* -> 15.2.6-1]
    #> - RcppEigen              [* -> 0.3.4.0.2]
    #> - RcppNumerical          [* -> 0.7-0]
    #> - RCurl                  [* -> 1.98-1.18]
    #> - renv                   [* -> 1.2.2]
    #> - reshape2               [* -> 1.4.5]
    #> - restfulr               [* -> 0.0.16]
    #> - rjson                  [* -> 0.2.23]
    #> - rlang                  [* -> 1.2.0]
    #> - rmarkdown              [* -> 2.31]
    #> - RSQLite                [* -> 3.52.0]
    #> - rstudioapi             [* -> 0.18.0]
    #> - S7                     [* -> 0.2.2]
    #> - sass                   [* -> 0.4.10]
    #> - scales                 [* -> 1.4.0]
    #> - scatterpie             [* -> 0.2.6]
    #> - snow                   [* -> 0.4-4]
    #> - SparseM                [* -> 1.84-2]
    #> - statmod                [* -> 1.5.1]
    #> - stringi                [* -> 1.8.7]
    #> - stringr                [* -> 1.6.0]
    #> - sys                    [* -> 3.4.3]
    #> - systemfonts            [* -> 1.3.2]
    #> - textshaping            [* -> 1.0.5]
    #> - tibble                 [* -> 3.3.1]
    #> - tidydr                 [* -> 0.0.6]
    #> - tidyr                  [* -> 1.3.2]
    #> - tidyselect             [* -> 1.2.1]
    #> - tidytree               [* -> 0.4.7]
    #> - tinytex                [* -> 0.59]
    #> - tweenr                 [* -> 2.0.3]
    #> - utf8                   [* -> 1.2.6]
    #> - vctrs                  [* -> 0.7.3]
    #> - viridisLite            [* -> 0.4.3]
    #> - whisker                [* -> 0.4.1]
    #> - withr                  [* -> 3.0.2]
    #> - writexl                [* -> 1.5.4]
    #> - xfun                   [* -> 0.57]
    #> - XML                    [* -> 3.99-0.23]
    #> - xml2                   [* -> 1.5.2]
    #> - yaml                   [* -> 2.3.12]
    #> - yulab.utils            [* -> 0.2.4]
    #> 
    #> # https://bioc.r-universe.dev ------------------------------------------------
    #> - DESeq2                 [* -> 1.51.7]
    #> - IRanges                [* -> 2.45.0]
    #> 
    #> The version of R recorded in the lockfile will be updated:
    #> - R                      [* -> 4.6.0]
    #> 
    #> - Lockfile written to "/var/folders/5q/v_ms_h9x6mv05dzlf94g48d00000gn/T//Rtmp3InutT/my_project_with_emma5b3a6946df25/analysis.lock".

## Session info

``` r

sessionInfo()
```

    #> R version 4.6.0 (2026-04-24)
    #> Platform: aarch64-apple-darwin23
    #> Running under: macOS Sequoia 15.7.2
    #> 
    #> Matrix products: default
    #> BLAS:   /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRblas.0.dylib 
    #> LAPACK: /Library/Frameworks/R.framework/Versions/4.6/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
    #> 
    #> locale:
    #> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    #> 
    #> time zone: Europe/Berlin
    #> tzcode source: internal
    #> 
    #> attached base packages:
    #> [1] stats4    stats     graphics  grDevices utils     datasets  methods  
    #> [8] base     
    #> 
    #> other attached packages:
    #>  [1] topGO_2.65.0                SparseM_1.84-2             
    #>  [3] GO.db_3.23.1                graph_1.91.0               
    #>  [5] mosdef_1.9.0                clusterProfiler_4.21.0     
    #>  [7] org.Hs.eg.db_3.23.1         AnnotationDbi_1.75.0       
    #>  [9] DESeq2_1.51.7               SummarizedExperiment_1.43.0
    #> [11] Biobase_2.73.1              MatrixGenerics_1.25.0      
    #> [13] matrixStats_1.5.0           GenomicRanges_1.65.0       
    #> [15] Seqinfo_1.3.0               IRanges_2.45.0             
    #> [17] S4Vectors_0.51.1            BiocGenerics_0.59.0        
    #> [19] generics_0.1.4              macrophage_1.29.0          
    #> [21] EMMA_0.3.0                  BiocStyle_2.41.0           
    #> 
    #> loaded via a namespace (and not attached):
    #>   [1] splines_4.6.0               BiocIO_1.23.3              
    #>   [3] filelock_1.0.3              bitops_1.0-9               
    #>   [5] ggplotify_0.1.3             BiasedUrn_2.0.12           
    #>   [7] tibble_3.3.1                polyclip_1.10-7            
    #>   [9] enrichit_0.1.4              XML_3.99-0.23              
    #>  [11] lifecycle_1.0.5             httr2_1.2.2                
    #>  [13] edgeR_4.9.9                 processx_3.9.0             
    #>  [15] lattice_0.22-9              MASS_7.3-65                
    #>  [17] magrittr_2.0.5              limma_3.69.0               
    #>  [19] plotly_4.12.0               sass_0.4.10                
    #>  [21] rmarkdown_2.31              jquerylib_0.1.4            
    #>  [23] yaml_2.3.12                 otel_0.2.0                 
    #>  [25] ggtangle_0.1.2              DBI_1.3.0                  
    #>  [27] RColorBrewer_1.1-3          abind_1.4-8                
    #>  [29] purrr_1.2.2                 RCurl_1.98-1.18            
    #>  [31] yulab.utils_0.2.4           tweenr_2.0.3               
    #>  [33] rappdirs_0.3.4              aisdk_1.1.0                
    #>  [35] gdtools_0.5.0               enrichplot_1.33.0          
    #>  [37] ggrepel_0.9.8               tidytree_0.4.7             
    #>  [39] pkgdown_2.2.0               codetools_0.2-20           
    #>  [41] DelayedArray_0.39.1         DOSE_4.7.0                 
    #>  [43] DT_0.34.0                   ggforce_0.5.0              
    #>  [45] tidyselect_1.2.1            aplot_0.2.9                
    #>  [47] UCSC.utils_1.9.0            farver_2.1.2               
    #>  [49] goseq_1.65.0                BiocFileCache_3.3.0        
    #>  [51] GenomicAlignments_1.49.0    jsonlite_2.0.0             
    #>  [53] systemfonts_1.3.2           bbmle_1.0.25.1             
    #>  [55] DeeDeeExperiment_1.3.0      progress_1.2.3             
    #>  [57] tools_4.6.0                 ggnewscale_0.5.2           
    #>  [59] treeio_1.37.0               ragg_1.5.2                 
    #>  [61] Rcpp_1.1.1-1.1              glue_1.8.1                 
    #>  [63] SparseArray_1.11.13         BiocBaseUtils_1.15.0       
    #>  [65] mgcv_1.9-4                  xfun_0.57                  
    #>  [67] geneLenDataBase_1.49.0      qvalue_2.45.0              
    #>  [69] GenomeInfoDb_1.49.0         dplyr_1.2.1                
    #>  [71] numDeriv_2016.8-1.1         withr_3.0.2                
    #>  [73] BiocManager_1.30.27         fastmap_1.2.0              
    #>  [75] callr_3.7.6                 digest_0.6.39              
    #>  [77] R6_2.6.1                    gridGraphics_0.5-1         
    #>  [79] textshaping_1.0.5           dichromat_2.0-0.1          
    #>  [81] biomaRt_2.69.0              RSQLite_3.52.0             
    #>  [83] cigarillo_1.3.0             tidyr_1.3.2                
    #>  [85] renv_1.2.2                  data.table_1.18.4          
    #>  [87] fontLiberation_0.1.0        rtracklayer_1.73.0         
    #>  [89] prettyunits_1.2.0           httr_1.4.8                 
    #>  [91] htmlwidgets_1.6.4           S4Arrays_1.13.0            
    #>  [93] scatterpie_0.2.6            pkgconfig_2.0.3            
    #>  [95] gtable_0.3.6                blob_1.3.0                 
    #>  [97] S7_0.2.2                    SingleCellExperiment_1.35.0
    #>  [99] XVector_0.53.0              htmltools_0.5.9            
    #> [101] fontBitstreamVera_0.1.1     bookdown_0.46              
    #> [103] scales_1.4.0                png_0.1-9                  
    #> [105] ggfun_0.2.0                 knitr_1.51                 
    #> [107] rstudioapi_0.18.0           reshape2_1.4.5             
    #> [109] rjson_0.2.23                coda_0.19-4.1              
    #> [111] nlme_3.1-169                curl_7.1.0                 
    #> [113] bdsmatrix_1.3-7             cachem_1.1.0               
    #> [115] stringr_1.6.0               parallel_4.6.0             
    #> [117] restfulr_0.0.16             desc_1.4.3                 
    #> [119] apeglm_1.35.0               pillar_1.11.1              
    #> [121] grid_4.6.0                  vctrs_0.7.3                
    #> [123] tidydr_0.0.6                dbplyr_2.5.2               
    #> [125] cluster_2.1.8.2             evaluate_1.0.5             
    #> [127] GenomicFeatures_1.65.0      mvtnorm_1.3-7              
    #> [129] cli_3.6.6                   locfit_1.5-9.12            
    #> [131] compiler_4.6.0              Rsamtools_2.29.0           
    #> [133] rlang_1.2.0                 crayon_1.5.3               
    #> [135] gprofiler2_0.2.4            emdbook_1.3.14             
    #> [137] plyr_1.8.9                  fs_2.1.0                   
    #> [139] writexl_1.5.4               ggiraph_0.9.6              
    #> [141] stringi_1.8.7               viridisLite_0.4.3          
    #> [143] BiocParallel_1.47.0         txdbmaker_1.9.0            
    #> [145] Biostrings_2.81.1           lazyeval_0.2.3             
    #> [147] GOSemSim_2.39.0             fontquiver_0.2.1           
    #> [149] Matrix_1.7-5                hms_1.1.4                  
    #> [151] patchwork_1.3.2             bit64_4.8.0                
    #> [153] ggplot2_4.0.3               statmod_1.5.1              
    #> [155] KEGGREST_1.53.0             igraph_2.3.1               
    #> [157] memoise_2.0.1               bslib_0.10.0               
    #> [159] ggtree_4.3.0                bit_4.6.0                  
    #> [161] ape_5.8-1                   gson_0.1.0

## References

Alasoo, Kaur, Julia Rodrigues, Subhankar Mukhopadhyay, et al. 2018.
“Shared genetic effects on chromatin and gene expression indicate a role
for enhancer priming in immune response.” *Nature Genetics* 50 (3):
424–31. <https://doi.org/10.1038/s41588-018-0046-7>.

Brazma, Alvis, Pascal Hingamp, John Quackenbush, et al. 2001. “Minimum
Information about a Microarray Experiment (MIAME)—Toward Standards for
Microarray Data.” *Nature Genetics* 29 (4): 365–71.
<https://doi.org/10.1038/ng1201-365>.

Khatri, Purvesh, Marina Sirota, and Atul J. Butte. 2012. “Ten Years of
Pathway Analysis: Current Approaches and Outstanding Challenges.” *PLoS
Computational Biology* 8 (2): e1002375.
<https://doi.org/10.1371/journal.pcbi.1002375>.

Subramanian, Aravind, Pablo Tamayo, Vamsi K. Mootha, et al. 2005. “Gene
Set Enrichment Analysis: A Knowledge-Based Approach for Interpreting
Genome-Wide Expression Profiles.” *Proceedings of the National Academy
of Sciences* 102 (43): 15545–50.
<https://doi.org/10.1073/pnas.0506580102>.

Wijesooriya, Kaumadi, Sameer A. Jadaan, Kaushalya L. Perera, Tanuveer
Kaur, and Mark Ziemann. 2022. “Urgent Need for Consistent Standards in
Functional Enrichment Analysis.” *PLOS Computational Biology* 18 (3):
e1009935. <https://doi.org/10.1371/journal.pcbi.1009935>.
