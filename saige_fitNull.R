library(SAIGE)
library(data.table)
library(stringr)

# parse in args
args <- commandArgs(trailingOnly=T)
plink.file.bed <- args[1] 
plink.file.bim <- args[2] 
plink.file.fam <- args[3]
pheno.file <- args[4]
outcome <- args[5]
outcome.type <- args[6]
covariate.string <- args[7]
id.col <- args[8]
label <- args[9]
threads <- as.numeric(args[10])
num.markers <- as.numeric(args[11])
inv.normalize.str <- args[12]

plink.file <- sub('\\.bed$', '', plink.file.bed)

covars <- unlist(str_split(covariate.string, ","))

pheno.header <- names(fread(pheno.file, data.table = F))

# what if id.col not in phenofile
if (!(id.col %in% pheno.header)) {
  stop("ID column not a column name in the phenotype file, stopping.")
}

# what if outcome not in phenofile
if (!(outcome %in% pheno.header)) {
  stop("Outcome not a column name in the phenotype file, stopping.")
}

# what if covars not in phenofile
if (any(!(covars %in% pheno.header))) {
  stop("One of more covariates not column names in the phenotype file, stopping.")
}

# convert invnorm to bool
if (startsWith(tolower(inv.normalize.str),"T")) {
  inv.normalize <- TRUE
} else {
  inv.normalize <- FALSE
}

fitNULLGLMM(plinkFile = plink.file, 
  phenoFile = pheno.file,
  phenoCol = outcome,
  traitType = outcome.type,
  invNormalize = inv.normalize,
  covarColList = covars,
  qCovarCol = NULL,
  sampleIDColinphenoFile = id.col,
  tol=0.02,
  maxiter=20,
  tolPCG=1e-5,
  maxiterPCG=500,
  nThreads = threads,
  Cutoff = 2,
  numMarkers = num.markers,
  skipModelFitting = F,
  outputPrefix = label)



