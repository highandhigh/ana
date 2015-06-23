library(rmongodb)
library(rjson)
source("r/mongoFunc.R")
source("conf/config.R")
mgdb <- mongo.create()

args = commandArgs(TRUE)
if(length(args) == 0){
  dateStr = format(Sys.time(),"%Y%m%d")
}else{
  dateStr = args[1]
}
#YYYYMMDD
insertToday(mgdb,namespace,dateStr,"sh")
insertToday(mgdb,namespace,dateStr,"sz")

insertToday(mgdb,adjTable,dateStr,"sh")
insertToday(mgdb,adjTable,dateStr,"sz")