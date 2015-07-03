#single is a data frame from context for a single stock data

#strategy setup 

moneytotal = 200000
source("r/metrics.R")
source("r/util.R")

sumClose10 = 0
sumClose20 = 0
sumClose25 = 0
sumClose350 = 0
calc = function(i,count){
  calTrueFluc(i)
  #20 low
  calAvgTFFluc(i,count)
  calAvgCloseDays(i,count,10)
  calAvgCloseDays(i,count,20)
  calAvgCloseDays(i,count,25)
  calAvgCloseDays(i,count,350)
}

sell = function(i, count){
  if(count >= 350 && share > 0 && 
     ((single[i,"Close"] < max(single[hold,"stop"]) && single[i,"Close"] < single[i,"AvgClose20"])
      || (single[i,"Close"] < single[i,"AvgClose10"] && single[i,"Close"] < single[i,"AvgClose20"] ))){
    profit <<- 0
    while(share > 0){
      moneyleft <<- moneyleft + single[i,"Close"] * single[hold[share],"position"]*100
      profit <<- profit + (single[i,"Close"] - single[hold[share],"Close"]) * 100 * single[hold[share],"position"]
      share <<- share - 1
    }
    #single stock is ok sell will sell all
    moneytotal <<- moneyleft
    single[i,"moneyleft"] <<- moneyleft
    single[i,"act"] <<- "sell"
    single[i,"profit"] <<- profit
    if(single[i,"Close"] < min(single[hold,"stop"])){
      print("[sell] at stop")
    }else{
      print("[sell] at trend")
    }
    print(single[i,])
    print("holding shares:")
    printAllStock(hold,single)
    hold <<- c()
    return(TRUE)
  }
  return(FALSE)
}

buy = function(i,count){
  if(count >= 350 && single[i,"Close"] > single[i,"AvgClose20"] &&  
     single[i,"Close"] >single[i,"AvgClose10"] && 
     single[i,"AvgClose25"] > single[i,"AvgClose350"]){
    if(share >= 4){
      print("try to buy but fail:")
      single[i,"act"] <<- "meet"
      print(single[i,])
      return(FALSE)
    }
    if(single[i,"Close"]*1.015 < single[i+1,"Open"]){
      print("fail to make the deal")
      single[i,"act"] <<- "fail"
      print(single[i,])
      print(single[i+1,])
      return(FALSE)
    }
    if(share > 0 && single[i,"Close"] < single[hold[share],"start"] + single[hold[share],"N"]/2){
      print("trend not obvious no buy")
      single[i,"act"] <<- "notrend"
      print(single[i,])
      return(FALSE)
    }
    
    #in case cannot buy in
    single[i,"start"] <<- single[i,"Close"]*1.015
    #stop is 2atr
    single[i,"stop"] <<- single[i,]$Close - 2*single[i,"N"]
    single[i,"position"] <<- as.integer( moneytotal * 0.01 / (single[i,"N"]*100))
    if(single[i,]$position*single[i,]$start*100 > moneyleft){
      print("not enough money left to buy targe , all in")
      single[i,]$position <<- as.integer(moneyleft/(single[i,]$start*100))
      if(single[i,]$position == 0){
        print("cannot afford a single share")  
        single[i,"act"]<<-"empty"
        print(single[i,])
        return(FALSE)
      }
    }
    moneyleft <<- moneyleft - single[i,]$position * single[i,]$start * 100
    
    #deal!
    single[i,]$moneyleft <<- moneyleft
    share <<- share+1
    single[i,]$share <<- share
    hold <<- c(hold,i)
    single[i,"act"] <<- "buy"
    
    print("[buy]hoding shares:")
    printAllStock(hold,single)
    #cannot sell on same day
  }
}
