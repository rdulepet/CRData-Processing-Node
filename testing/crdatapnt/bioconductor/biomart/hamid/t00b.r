### Getting data from biomaRt ###
library(biomaRt)
mart = useMart("snp",dataset="hsapiens_snp")
# to see list of commands, type: listAttributes(mart)

### Get SNP data from Biomart ###
geneList=read.table(file="C:\\rruby\\t00\\t00.data",header=T,sep="\t",quote="")
values=paste(as.character(geneList[,1]),"",sep="")
snpList=getBM(attributes= c("refsnp_id","dbsnp","chr_name","chrom_start","chrom_strand","allele","ensembl_venter","ensembl_watson","ensembl_gene_stable_id","consequence_type_tv","translation_start","translation_end"),filters="ensembl_gene",values=values,mart=mart)
dim(snpList)
write.csv(snpList,file="C:\\rruby\\t00\\output.csv")

### Read SNP data file from Biomart output & extract Watson / Venter significant hits
SNPdata=read.csv(file="C:\\rruby\\t00\\output.csv")

vVars	<- c("ensembl_venter", "ensembl_gene_stable_id", "consequence_type_tv", "refsnp_id")
vData	<- SNPdata[vVars]

attach(vData)
i 		<- which(ensembl_venter!="" & consequence_type_tv!="UPSTREAM" & consequence_type_tv!="INTRONIC" & consequence_type_tv!="SYNONYMOUS_CODING" & consequence_type_tv!="DOWNSTREAM" & consequence_type_tv!="WITHIN_NON_CODING_GENE")
vSNPs	<- vData[i,]
detach(vData)
write.csv(vSNPs, file = "C:\\rruby\\t00\\vSNPs.csv")

### OK to here

wVars	<- c("ensembl_watson", "ensembl_gene_stable_id", "consequence_type_tv", "refsnp_id")
wData	<- SNPdata[wVars]

attach(wData)
i 		<- which(ensembl_watson!="" & consequence_type_tv!="UPSTREAM" & consequence_type_tv!="INTRONIC" & consequence_type_tv!="SYNONYMOUS_CODING" & consequence_type_tv!="DOWNSTREAM" & consequence_type_tv!="WITHIN_NON_CODING_GENE")
wSNPs	<- wData[i,]
detach(wData)
write.csv(wSNPs, file = "C:\\rruby\\t00\\wSNPs.csv")


### count SNP types per gene ###
snpList=read.csv("C:\\rruby\\t00\\Venter_nsSNPs_nonRegulatory.csv")

i 		<- which(snpList$consequence_type_tv=="NON_SYNONYMOUS_CODING")
nsSNPs	<- snpList[i,]
V_nsSNP_counts <- table(nsSNPs$Associated.Gene.Name)
write.csv(V_nsSNP_counts, file = "C:\\rruby\\t00\\Venter_nsSNP_counts.csv")

