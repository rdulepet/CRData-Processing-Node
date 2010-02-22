library("R2HTML")

# START - CRDATA Instrumented Code
job_log <- file("job.log", open="wt")
sink(job_log)
sink(job_log, type="message")


target <- HTMLInitFile(getwd(), filename="index")
HTML("<br>Don't forget to use the CSS file in order to benefit from fixed-width font", file=target)

origjj = read.table(aFile1)
HTML(origjj,file=target)

jj = ts(origjj, start=aStart, frequency=aFrequency)
HTML(jj,file=target)

graph1=aGraph1
png(file.path(getwd(),graph1))
plot(jj, ylab=aYlab1, main=aMain1)
dev.off()

# Insert graph to the HTML output
HTMLInsertGraph(graph1,file=target,caption=aCaption1)

##################SECOND PART REPEATED##########

origjj = read.table(aFile2)
HTML(origjj,file=target)

jj = ts(origjj, start=aStart, frequency=aFrequency)
HTML(jj,file=target)

graph2=aGraph2
png(file.path(getwd(),graph2))
plot(jj, ylab=aYlab2, main=aMain2)
dev.off()

# Insert graph to the HTML output
HTMLInsertGraph(graph2,file=target,caption=aCaption2)


HTMLEndFile()

# END - CRDATA Instrumented Code
sink()
