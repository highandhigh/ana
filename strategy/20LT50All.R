#single is a data frame from context for a single stock data

#strategy setup 

moneytotal = 200000
selColumn = c("id","Date","High","Low","Open","Close","AvgLow5","AvgClose5","AvgHigh60")


source("r/metrics.R")
source("r/util.R")

sell = function(dayData){
  if(share == 0) return(FALSE)
  holdingList = record[hold,"id"]
  newHold = c()
  profit = 0
  for(i in 1:length(holdingList)){
    optional = dayData[dayData$id == holdingList[i] & dayData$AvgLow5 < dayData$AvgHigh60,]
    if(nrow(optional) == 0) {
      newHold = c(newHold,hold[i])
      next
    }
    share <<- share - 1
    optional$share = share
    moneyleft <<- moneyleft + optional[1,"Close"] * record[hold[i],"position"]*100
    optional$"moneyleft" = moneyleft
    profit = profit + (optional[1,"Close"] - record[hold[i],"start"]) * record[hold[i],"position"]*100
    optional$"profit" = profit
    optional$rate = 0
    optional$start = record[hold[i],"start"]
    optional$stop = record[hold[i],"stop"]
    optional$position = record[hold[i],"position"]
    optional$"act" = "sell"
    record <<- rbind(record,optional)
    print(optional)
  }
  if(length(hold) == length(newHold)) return(FALSE)
  hold <<- newHold
  return(TRUE)
}

buy = function(dayData){
  if(moneyleft < 3000 ) return(FALSE)
  optional = dayData[dayData$AvgLow5 > dayData$AvgHigh60 & !is.na(dayData$N),]
  if(nrow(optional) == 0){
    print("no optional choise")
    return(FALSE)
  }
  optional$rate = (optional$Close - optional$AvgClose5)/optional$AvgClose5
  buyStock = head(optional[order(optional$rate,decreasing = T),],1)
  if(share >= 6){
    print("try to buy but full:")
    buyStock$act =  "meet"
    print(buyStock)
    return(FALSE)
  }
    #in case cannot buy in
  buyStock$start =  buyStock$Close*1.015
  buyStock$stop = buyStock$Close - buyStock$N
  buyStock$position = as.integer( moneytotal * 0.01 / (buyStock$N*100))
  if(buyStock$position*buyStock$start*100 > moneyleft){
    print("not enough money left to buy targe , all in")
    buyStock$position =  as.integer(moneyleft/(buyStock$start*100))
    if(buyStock$position == 0){
      print("cannot afford a single share")  
      buyStock$act = "empty"
      print(buyStock)
      return(FALSE)
    }
  }
  moneyleft <<- moneyleft - buyStock$position * buyStock$start * 100
    #deal!
  buyStock$moneyleft =  moneyleft
  buyStock$act = "buy"
  share <<- share+1
  buyStock$share = share
  record <<- rbind(record,buyStock)
  hold <<- c(hold,nrow(record))
  print(buyStock)
  #print("[buy]hoding shares:")
  #printAllStock(hold,record)
}
