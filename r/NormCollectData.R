#we need adjusted value to run all the test
#mainly leverage library(quantmod)
library(quantmod)
library(rmongodb)
library(rjson)
source("conf/config.R")

#market =SS SZ
updateSingle = function(id,market,startDate,endDate,mongodb,tableName){
  if(!mongo.is.connected(mongodb)){
    print("mongo connection is already closed!")
    return()
  }
  sid = paste(id,".",market,sep="")
  cat(paste("getting...",id,sep=" "))
  input = try(getSymbols(sid,from = startDate,to=endDate,auto.assign = FALSE))
  if(is.null(nrow(input)) ) return()
  adjusted = adjustOHLC(input,symbol.name = sid)
  stockData = data.frame(adjusted)
  colnames(stockData) = yahooSchema
  stockData$Date = rownames(stockData)
  stockData$id = id
  if(nrow(stockData) == 0){
    print(paste("[ERROR] cannot find data for id:",id,sep=""))
  }else{
    #data entry check
    days = as.Date(stockData[nrow(stockData),"Date"],"%Y-%m-%d") - as.Date(stockData[1,"Date"],"%Y-%m-%d")
    if(nrow(stockData) < days*2/3){
      print(paste("[WARNING] id:",id," seems don't have enough data:",nrow(stockData),". Please check!",sep=""))
    }else{
      cat(paste(" and ",nrow(stockData)," inserted!\n"))
      
    }
  }
  for( i in seq(1,nrow(stockData))){
    json = toJSON(stockData[i,])
    bson = mongo.bson.from.JSON(json)
    if(!mongo.insert(mongodb,tableName,bson)){
      print(paste("failed to insert:",json))
    }
  }
}

startDate= "2000-01-01"
endDate = "2015-06-19"
mongodb = mongo.create()
updateSingle("600754","SH","2000-01-01","2015-06-19",mongodb,adjTable)
shlist = readLines("conf/ss_list.conf")
shlist = shlist[shlist>600751]
lapply(shlist,updateSingle,market="SS",startDate,endDate,mongodb,adjTable)
