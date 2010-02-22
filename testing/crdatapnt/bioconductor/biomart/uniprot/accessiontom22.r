source("setup.r")
attributes = c("protein_name","gene_name","organism","go_id","accession")
#values = list(gene_name=c('tom22_yeast'), interpro_id= 'IPR005683')
values = list(protein_name=c('Mitochondrial import receptor subunit TOM22'),gene_name=c('TOM22'),accession=c('P49334'))
#values = c("tom22_yeast","IPR005683")
filters = c("protein_name","gene_name","accession")
results=getBM(attributes= attributes,filters=filters,values=values,mart=mart)
print(results)

