library("R2HTML")
crdata_job_log <- file("job.log", open="wt")
sink(crdata_job_log)
crdata_target <- HTMLInitFile(getwd(), filename="index")
tryCatch({
source("/home/michael/crdatapn/temp/62da7647-5b6f-2ab0-2ad6-eedff9fbe61e/inc_62da7647-5b6f-2ab0-2ad6-eedff9fbe61e.r")
HTML("Arbitrary Text 00", file=crdata_target)

x = c(0,1,2,3,4,5)

HTML(x, file=crdata_target)


png(file.path(getwd(),"d6e2ade9-6aee-e155-8330-9660e7a3c0d3.png"))
plot(x)

dev.off()
HTMLInsertGraph("d6e2ade9-6aee-e155-8330-9660e7a3c0d3.png", file=crdata_target,caption="")

HTML("Arbitrary Text 01", file=crdata_target)


}, interrupt = function(ex) {
print ("got exception: Failed Job");
 returnstatus="FAILED JOB, PLEASE CHECK LOG"; 
HTML(returnstatus, file=crdata_target);
print(ex);
}, error = function(ex) {
print ("got error: Failed Job");
 returnstatus="FAILED JOB, PLEASE CHECK LOG"; 
HTML(returnstatus, file=crdata_target);
print(ex);
}, finally = {
print("JOB ENDED");
HTMLEndFile()
sink()
close(crdata_job_log)

})
