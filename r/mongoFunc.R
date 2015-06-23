insertHistory = function(id,mongoConnection,tableName){
  if(!mongo.is.connected(mongoConnection)){
    print("mongo connection is already closed!")
    return()
  }
  input = read.table(paste("data/history/",id,".csv",sep=""),sep=",",header = TRUE)
  id = uniType(id)
  print(paste("start to insert ",id," with ", nrow(input), sep =""))
  input$id=id
  for( i in seq(1,nrow(input))){
    json = toJSON(input[i,])
    bson = mongo.bson.from.JSON(json)
    if(!mongo.insert(mongoConnection,tableName,bson)){
      print(paste("failed to insert:",json))
    }
  }
}

insertToday = function(mongoConnection,tableName,dateStr,select){
  if(!mongo.is.connected(mongoConnection)){
    print("mongo connection is already closed!")
    return
  }
  input = read.table(paste("data/",dateStr,"/",select,"_data.csv",sep=""),sep=",",header = TRUE)
  input$Date = as.character(as.Date(dateStr,"%Y%m%d"))
  print(paste("start to insert on ",dateStr," with ", nrow(input), sep =""))
  count = 0
  for( i in seq(1,nrow(input))){
    if(input[i,'Volume'] == 0 ) next
    count= count+1
    json = toJSON(input[i,])
    if(tableName == "database.adjstock"){
      json = str_replace(json,select,"")
    }
    bson = mongo.bson.from.JSON(json)
    if(!mongo.insert(mongoConnection,tableName,bson)){
      print(paste("failed to insert:",json))
    }
  }
  print(paste("On date:",dateStr," inserted ", count," records",sep=""))
}

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