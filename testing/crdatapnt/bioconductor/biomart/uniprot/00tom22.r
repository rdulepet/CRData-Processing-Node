source("setup.r")
attributes = c("gene_name","organism","go_id")
#values = list(gene_name=c('tom22_yeast'), interpro_id= 'IPR005683')
values = list(gene_name=c('TOM22'))
#values = c("tom22_yeast","IPR005683")
filters = c("gene_name")
results=getBM(attributes= attributes,filters=filters,values=values,mart=mart)
print(results)


