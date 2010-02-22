    #    <    crdata_title>This is brand new CRDATA run report</  crdata_title>
tmp <- as.data.frame(matrix(rnorm(100),ncol=10))
summary(tmp)
#<crdata_object>tmp</crdata_object>
#<crdata_section/>

#<crdata_image caption="First Graph">
plot(tmp)
#</crdata_image>

#<crdata_image caption="Second Graph">plot(tmp)
#</crdata_image>
#<crdata_image caption="Third Graph">plot(tmp)</crdata_image>

#<crdata_image>plot(tmp)</crdata_image>
