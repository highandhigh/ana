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
    bson = mongo.bson.from.JSON(json)
    if(!mongo.insert(mongoConnection,tableName,bson)){
      print(paste("failed to insert:",json))
    }
  }
  print(paste("On date:",dateStr," inserted ", count," records",sep=""))
}