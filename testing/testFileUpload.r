library("R2HTML")

# START - CRDATA Instrumented Code
job_log <- file("job.log", open="wt")
sink(job_log)
sink(job_log, type="message")


target <- HTMLInitFile(getwd(), filename="index")
HTML("<br>Don't forget to use the CSS file in order to benefit from fixed-width font", file=target)

origjj = read.table(aFile)
HTML(origjj,file=target)

jj = ts(origjj, start=1960, frequency=4)
HTML(jj,file=target)

graph1="graph2.png"
png(file.path(getwd(),graph1))
plot(jj, ylab="Earnings per Share", main="J & J")
dev.off()

# Insert graph to the HTML output
HTMLInsertGraph(graph1,file=target,caption="Some time series stuff")

HTMLEndFile()

# END - CRDATA Instrumented Code
sink()
