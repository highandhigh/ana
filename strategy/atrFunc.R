#single is a data frame from context for a single stock data

#strategy setup 

moneytotal = 200000


close = 350
closeStr = paste("AvgClose",close,sep="")

source("r/metrics.R")
source("r/util.R")
calc = function(i,count){
  calTrueFluc(i)
  #20 low
  calAvgTFFluc(i,count)
  calAvgClose(i,count,close)
}

sell = function(i, count){
  if(count >= 351 && share > 0 && single[i,"Close"]  < single[i,closeStr] - 3* single[i,"N"]){
    profit = 0
    while(share > 0){
      moneyleft <<- moneyleft + single[i,"Close"] * single[hold[share],"position"]*100
      profit = profit + (single[i,"Close"] - single[hold[share],"Close"]) * 100 * single[hold[share],"position"]
      share <<- share - 1
    }
    #single stock is ok sell will sell all
    moneytotal <<- moneyleft
    single[i,"moneyleft"] <<- moneyleft
    single[i,"act"] <<- "sell"
    single[i,"profit"] <<- profit
    print("[sell] at trend")
    print(single[i,])
    print("holding shares:")
    printAllStock(hold,single)
    hold <<- c()
    return(TRUE)
  }
  return(FALSE)
}

buy = function(i,count){
  if(count >= 351 && single[i,"Close"] > single[i,closeStr] + 7 * single[i,"N"]){
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
    single[i,"stop"] <<- single[i,]$Close - single[i,"N"]
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
    single[i,"moneyleft"] <<- moneyleft
    share <<- share+1
    single[i,"share"] <<- share
    hold <<- c(hold,i)
    single[i,"act"] <<- "buy"
    
    print("[buy]hoding shares:")
    printAllStock(hold,single)
    #cannot sell on same day
  }
}
