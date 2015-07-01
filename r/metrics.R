# i > 1
calTrueFluc= function(i){
  single[i,"TrueFluc"] <<- trueFluc(H=single[i,"High"],L=single[i,"Low"],PDC = single[i-1,"Close"] )
}

#must be called after TrueFluc
sumTF = 0
calAvgTFFluc = function(i,count){
  sumTF <<- sumTF + single[i,"TrueFluc"]
  if(count ==  20){
    single[i,"N"] <<- sumTF / 20
  }else if(count > 20){
    single[i,"N"] <<- (19*single[i-1,"N"]+single[i,"TrueFluc"])/20
  }
}

#day = 20,50,70,...
# i > day
sumClose = 0
calAvgClose = function(i,count,day){
  str = paste("AvgClose",day,sep="")
  sdStr = paste("SdClose",day,sep="")
  sumClose <<- sumClose + single[i,"Low"]
  if(count ==  day){
    single[i,str] <<- sumClose / day
    single[i,sdStr] <<- sd(single[seq(i,i-day+1),"Close"])
  }else if(count > day){
    sumClose <<- sumClose - single[i - day,"Low"]
    single[i,str] <<- sumClose / day
    single[i,sdStr] <<- sd(single[seq(i,i-day+1),"Close"])
  }
  
}

#day = 20,50,70,...
# i > day
sumLow = 0
calAvgLow = function(i,count,day){
  str = paste("AvgLow",day,sep="")
  sumLow <<- sumLow + single[i,"Low"]
  if(count ==  day){
    single[i,str] <<- sumLow / day
  }else if(count > day){
    sumLow <<- sumLow - single[i - day,"Low"]
    single[i,str] <<- sumLow / day
  }
}

#day = 20,50,70,...
# i > day
sumHigh = 0
calAvgHigh = function(i,count,day){
  str = paste("AvgHigh",day,sep="")
  sumHigh <<- sumHigh + single[i,"High"]
  if(count ==  day){
    single[i,str] <<- sumHigh / day
  }else if(count > day){
    sumHigh <<- sumHigh - single[i - day,"High"]
    single[i,str] <<- sumHigh / day
  }
}

getYearEndValue = function(single,year){
  yearDf = subset(single,as.character(single$Date,"%Y")==as.character(year))
  yearEndValue = yearDf[nrow(yearDf),"Close"]
  operation = subset(yearDf,yearDf$act == "sell" | yearDf$act == "buy")
  lastOp = nrow(operation)
  if(lastOp == 0) return(NA)
  if(operation[lastOp,"act"] == "sell" ) return(operation[lastOp,"moneyleft"])
  res = operation[lastOp,"moneyleft"]
  position = 0
  while(lastOp > 0 && operation[lastOp,"share"] > 0 ){
    position = position + operation[lastOp,"position"]
    lastOp = lastOp - 1
  }
  return(res+yearEndValue*position*100)
}



getSummary = function(df,strategyStr){
  operation = subset(df,df$act == "sell" | df$act == "buy")
  sell = operation[operation$act == "sell",]
  if(nrow(sell) == 0){
    print(paste("no sell operation at all, money left:",sum(single[hold,"position"])*100*17.07))
    return()
  }
  buy = operation[operation$act == "buy",]
  fit = lm(sell$moneyleft~sell$Date)
  plot(sell$Date,sell$moneyleft,type='l',col="blue",ylim = range(0,1200000),xlab="date",ylab="money",main = strategyStr)
  points(sell$Date,sell$moneyleft,pch=20)
  points(buy$Date,buy$moneyleft,pch=4,col = "green")
  abline(coef(fit),col= "RED")
  
  yearStart = as.numeric(as.character(head(df$Date,1),"%Y"))
  yearEnd = as.numeric(as.character(tail(df$Date,1),"%Y"))
  yearDf = data.frame(year = seq(yearStart,yearEnd))
  yearDf$value=sapply(yearDf$year,getYearEndValue,single=df)
  
  climax = 200000
  for(i in seq(2,nrow(yearDf))){
    yearDf[i,"ror"] = (yearDf[i,"value"] - yearDf[i-1,"value"]) / yearDf[i-1,"value"]
    yearDf[i,"netror"] = yearDf[i,"ror"] - 0.035
  }
  barplot(yearDf$value,xlab = "year",ylab = "Year End Money",col = rainbow(20))
  #max 
  cur = c()
  
  interval = c()
  for(i in seq(2,nrow(sell)-1)){
    if(sell[i,"moneyleft"] > sell[i-1,"moneyleft"] && sell[i,"moneyleft"] > sell[i+1,"moneyleft"]){
      climax = sell[i,"moneyleft"]
      if(is.null(cur)){
        cur = sell[i,"Date"]
      }
      else{
        interval = c(interval,as.numeric(sell[i,"Date"] - cur))
        cur = sell[i,"Date"]
      }
    }
    if(sell[i,"moneyleft"] < sell[i-1,"moneyleft"] && sell[i,"moneyleft"] < sell[i+1,"moneyleft"]){
      loss = c(loss,(climax - sell[i,"moneyleft"])/climax)
    }
  }
  
  
  res=list()
  res["finalMoney"] = tail(sell,1)$moneyleft
  res["rate"] = res[["finalMoney"]] / 200000
  res["yearRate"] = (res[["rate"]])^(1/15)
  res["RAR"]=coef(fit)[2]
  res["buyTimes"] = nrow(buy)
  res["sellTimes"] = nrow(sell)
  res["gainTimes"] = nrow(subset(sell,profit>0))
  res["gainRate"] = res[["gainTimes"]] / res[["sellTimes"]]
  res["maxDeclineTime"] = max(interval)
  res["rorsd"] = sd(yearDf$ror,na.rm = T)
  #sharp ratio is return / variacne ratio
  res["sharp"] = mean(yearDf$netror,na.rm = T)/sd(yearDf$netror,na.rm=T)
  #mar ratio is return / max_loss
  res["mar"] = res[["yearRate"]]/max(loss)
  rorfit = lm(data = yearDf ,ror~year)
  res["rsquare"] = summary(rorfit)$r.squared
  print(paste(strategyStr,":",toJSON(res),sep=""))
}
