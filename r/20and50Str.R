count = 0
sumTF = 0
sumHigh = 0
sumLow = 0
share = 0
moneyleft = 200000
moneytotal = 200000
hold = data.frame()
file.remove("log/20and50Str.log")
sink("log/20and50Str.log")
single$action = ""
single$share = 0
single$moneyleft = 0
single$profit = 0

for(i in seq(2,nrow(single)-1)){
  #calculation part
  count = count + 1
  single[i,"TrueFluc"] = trueFluc(H=single[i,"High"],L=single[i,"Low"],PDC = single[i-1,"Close"] )
  sumTF = sumTF + single[i,"TrueFluc"]
  sumHigh = sumHigh + single[i,"High"]
  sumLow = sumLow + single[i,"Low"]
  if(count ==  20){
    single[i,"N"] = sumTF / 20
    single[i,"AvgLow20"] = sumLow /20
  }else if(count > 20){
    single[i,"N"] = (19*single[i-1,"N"]+single[i,"TrueFluc"])/20
    sumLow = sumLow - single[i - 20,"Low"]
    single[i,"AvgLow20"] = sumLow /20
  }
  if(count == 50){
    single[i,"AvgHigh50"] = sumHigh/50;
  }else if(count > 50){
    sumHigh = sumHigh - single[i-50,"High"]
    single[i,"AvgHigh50"] = sumHigh/50;
  }
  #action part
  #buy
  if(count >= 50 && single[i,"Close"] > single[i,"AvgHigh50"] &&  single[i,"Close"] >single[i,"AvgLow20"]){
    if(share >= 4){
      print("try to buy but fail:")
      single[i,"act"] = "meet"
      print(single[i,])
      next
    }
    if(single[i,"Close"]*1.015 < single[i+1,"Open"]){
      print("fail to make the deal")
      print(single[i,])
      print(single[i+1,])
      next
    }
    buy = single[i,]
    #in case cannot buy in
    buy$Close = single[i,"Close"]*1.015
    buy$stop = buy$Close - single[i,"N"]
    buy$position = as.integer(moneytotal * 0.01 / (single[i,"N"]*100))
    if(buy$position*buy$Close*100 > moneyleft){
      print("not enough money left to buy targe , all in")
      buy$position = as.integer(moneyleft/(buy$Close*100))
      if(buy$position == 0){
        print("cannot afford a single share")   
        print(single[i,])
        next
      }
    }
    moneyleft = moneyleft - buy$position * buy$Close * 100
    
    #deal!
    buy$moneyleft = moneyleft
    single[i,"moneyleft"] = moneyleft
    share = share+1
    buy$share = share
    single[i,"share"] = share
    hold = rbind(hold,buy)
    single[i,"act"] = "buy"
    print("[buy] at")
    print(single[i,])
    print("hoding shares:")
    print(hold)
    #cannot sell on same day
    next
  }
  #sell with stop and sell with trends
  if(count >=50 && share > 0 && (single[i,"Close"] < max(hold[,"stop"]) || single[i,"Close"] < single[i,"AvgLow20"])){
    profit = 0
    while(share > 0){
      moneyleft = moneyleft + single[i,"Close"] * hold[share,"position"]*100
      profit = profit + (single[i,"Close"] - hold[share,"Close"]) * 100 * hold[share,"position"]
      share = share - 1
    }
    #single stock is ok sell will sell all
    moneytotal = moneyleft
    single[i,"moneyleft"] = moneyleft
    single[i,"act"] = "sell"
    single[i,"profit"] = profit
    if(single[i,"Close"] < min(hold[,"stop"])){
      print("[sell] at stop")
    }else{
      print("[sell] at trend")
    }
    print(single[i,])
    print("holding shares:")
    print(hold)
    hold = data.frame()
  }
}
write.table(single,"log/20and50Str.csv")
sink()
