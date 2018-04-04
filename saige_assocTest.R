library(SAIGE)
library(data.table)

# parse in args
args <- commandArgs(trailingOnly=T)
vcf.file <- args[1] 
vcf.index <- args[2]
sample.file <- args[3]
null.file <- args[4]
variance.file <- args[5]
label <- args[6]
min.maf <- as.numeric(args[7])
min.mac <- as.numeric(args[8])
out.case.control.str = args[9]

if (startsWith(tolower(out.case.control.str), "t")){
  out.case.control <- T
} else {
  out.case.control <- F
}

SPAGMMATtest(dosageFile="",
  dosageFileNrowSkip="",
  dosageFileNcolSkip="",
  dosageFilecolnamesSkip="",
  vcfFile=vcf.file,
  vcfFileIndex=vcf.index,
  vcfField="GT",
  bgenFile="",
  bgenFileIndex="",
  savFile="",
  savFileIndex="",		
  chrom="0",
  start=1,
  end=250000000,
  sampleFile=sample.file,
  GMMATmodelFile=null.file,
  varianceRatioFile=variance.file,
  SAIGEOutputFile=label,
  minMAF = min.maf,
  minMAC = min.mac,
  numLinesOutput = 10000,
  IsOutputAFinCaseCtrl = out.case.control
  )



