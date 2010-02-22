#<crdata_text>Arbitrary Text 00</crdata_text>

x = c(0,1,2,3,4,5)

#<crdata_object>x</crdata_object>

y = read.table(aFile)

#<crdata_text>This is the contents of the file</crdata_text>

#<crdata_object>y</crdata_object>

#<crdata_text>Line One Items 2 thru 6</crdata_text>

za = as.integer(y[1,2:6])

#<crdata_object>za</crdata_object>

#<crdata_text>Line Two Items 3 thru 7</crdata_text>

zb = as.integer(y[2,3:7])

#<crdata_object>zb</crdata_object>

#<crdata_text>Line Three Items 4 thru 8</crdata_text>

zc = as.integer(y[3,4:8])

#<crdata_object>zc</crdata_object>

#<crdata_text>Arbitrary Text 01</crdata_text>

