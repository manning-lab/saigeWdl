library(qqman)
library(data.table)
library(stringr)

# Parse inputs
input_args <- commandArgs(trailingOnly=T)
pval.threshold <- as.numeric(input_args[1])
label <- input_args[2]
assoc.files <- unlist(strsplit(input_args[3],","))

pval <- "p.value"

# Stop if no assoc files
if (length(assoc.files) == 0){
  fwrite(list(),paste(label, ".assoc.csv", sep=""),sep=",",row.names=F)
  fwrite(list(), paste(label, ".topassoc.csv", sep=""),row.names=F)
  pdf(paste(label,".association.plots.png",sep=""),width=8,height=8)
  dev.off()
  
} else {

  # Prep for association files
  assoc.compilation <- c() 
  
  # Loop through association files
  for (i in seq(1,length(assoc.files))) {
    assoc <- fread(assoc.files[i], data.table=F, sep=" ")
    
    # Check that the file is not empty
    if (!is.na(assoc)[1]){
      assoc <- assoc[!is.na(assoc[,pval]),]
      print(dim(assoc))
      
      # Write the results out to a master file
      if (i == 1) {
        write.table(assoc,paste(label, ".assoc.csv", sep=""),sep=",",row.names=F)
      } else {
        write.table(assoc,paste(label, ".assoc.csv", sep=""),col.names=FALSE,sep=",",row.names=F, append=TRUE)
      }	
    }
  }
  
  # Read master file back in
  assoc.compilation <- fread(paste(label, ".assoc.csv", sep=""),sep=",",header=T,stringsAsFactors=FALSE,showProgress=TRUE,data.table=FALSE)
  
  # Make sure the columns are in the right format
  assoc.compilation$chr <- as.numeric(as.character(assoc.compilation$CHR))
  assoc.compilation$pos <- as.numeric(as.character(assoc.compilation$POS))
  assoc.compilation$P <- as.numeric(as.character(assoc.compilation[,pval]))
  
  # Write out the top results
  fwrite(assoc.compilation[assoc.compilation[,pval] < pval.threshold, ], paste(label, ".topassoc.csv", sep=""), sep=",", row.names = F)
  
  # QQ plots by maf
  png(filename = paste(label,".association.plots.png",sep=""),width = 11, height = 11, units = "in", res=400)#, type = "cairo")
  par(mfrow=c(3,3))
  
  # All variants
  qq(assoc.compilation$P,main="All variants")
  
  # Common variants
  qq(assoc.compilation$P[assoc.compilation$AF_Allele2>0.05],main="Variants with MAF>0.05")
  
  # Rare/Low frequency variants
  qq(assoc.compilation$P[assoc.compilation$AF_Allele2<=0.05],main="Variants with MAF<=0.05")
  
  # Manhattan plots by maf
  # All variants
  manhattan(assoc.compilation,chr="chr",bp="pos",p="P", main="All variants")
  
  # Common variants
  manhattan(assoc.compilation[assoc.compilation$AF_Allele2>0.05,],chr="chr",bp="pos",p="P", main="Variants with MAF>0.05")
  
  # Rare/Low frequency variants
  manhattan(assoc.compilation[assoc.compilation$AF_Allele2<=0.05,],chr="chr",bp="pos",p="P", main="Variants with MAF<=0.05")
  dev.off()
}
