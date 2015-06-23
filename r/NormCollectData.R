#we need adjusted value to run all the test
#mainly leverage library(quantmod)
library(quantmod)
library(rmongodb)
library(rjson)
source("conf/config.R")
source("r/mongoFunc.R")

startDate= "2014-06-19"
endDate = "2015-06-20"
mongodb = mongo.create()

#calling function is like
##updateSingle("600754","SH","2000-01-01","2015-06-19",mongodb,adjTable)
shlist = readLines("conf/ss_list.conf")
#shlist = shlist[shlist>=601999]
sink("log/running.log")
lapply(shlist,updateSingle,market="SS",startDate,endDate,mongodb,adjTable)
sink()

szlist = readLines("conf/sz_list.conf")
sink("log/szrunning.log")
lapply(shlist,updateSingle,market="SZ",startDate,endDate,mongodb,adjTable)
sink()
