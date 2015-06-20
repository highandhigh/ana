library(rmongodb)
library(rjson)
source("conf/config.R")
source("r/mongoFunc.R")
mgdb <- mongo.create()

historyFiles = as.list(str_replace(list.files("data/history/"),".csv",""))
lapply(historyFiles,insertHistory, mongoConnection=mgdb,tableName = namespace)