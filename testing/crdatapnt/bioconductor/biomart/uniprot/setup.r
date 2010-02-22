### Getting data from biomaRt
### setwd("c:\\crdatapnt\\bioconductor\\biomart\\uniprot")

library(biomaRt)

### listMarts()
### mart = useMart("uniprot_mart")
### listDatasets("mart")
mart = useMart("uniprot_mart",dataset="UNIPROT")
###listAttributes(mart)

