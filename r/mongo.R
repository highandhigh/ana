library(rmongodb)
library(rjson)


mongodb <- mongo.create()

getStockDFFromDB=function(mongodb,id){
  buf <- mongo.bson.buffer.create()
  mongo.bson.buffer.append(buf,"id", id)
  query <- mongo.bson.from.buffer(buf)
  cur <- mongo.find(mongodb, adjTable, query = query)
  df = mongo.cursor.to.data.frame(cur)
  df$Date  = as.Date(df$Date,format= "%Y-%m-%d")
  df = subset(df,df$Volume>0)
  return(df)
  count = 0
  sum = 0
  for(i in seq(2,nrow(df))){
    count = count + 1
    df[i,"TrueFluc"] = trueFluc(H=df[i,"High"],L=df[i,"Low"],PDC = df[i-1,"Close"] )
    sum = sum + df[i,"TrueFluc"]
    if(count ==  20){
      df[i,"N"] = sum / 20;
    }else if(count > 20){fro
      df[i,"N"] = (19*df[i-1,"N"]+df[i,"TrueFluc"])/20
    }
  }
}



plot(df$Date,df$Open)
store = df