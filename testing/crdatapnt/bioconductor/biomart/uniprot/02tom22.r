source("setup.r")
attributes = c("protein_name","gene_name","organism","go_id")
values = list(protein_name=c('Mitochondrial import receptor subunit TOM22'))
filters = c("protein_name")
results=getBM(attributes= attributes,filters=filters,values=values,mart=mart)
print(results)


