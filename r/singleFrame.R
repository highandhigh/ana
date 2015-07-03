#strategy setup
#strategyStr = "20and50StrFunc"
#strategyStr = "20and50StrFunc2"
#strategyStr = "20LT50StrFunc"
#strategyStr = "20LT50StrFunc2"
#strategyStr = "20LT50StrFunc3"
#strategyStr = "atrFunc"
#strategyStr = "atrFunc2"
#strategyStr="BollingerFunc"
strategyStr="Donchian"
source(paste("strategy/",strategyStr,".R",sep=""))
single = subset(allStock,id =="600000")

#init
count = 0
share = 0
moneyleft = moneytotal
single$share = 0
single$moneyleft = 0
single$profit = 0
hold = c()

logFile = paste("log/",strategyStr,".log",sep="")
file.remove(logFile)
sink(logFile)

#startRow = 180
#endRow = 279
startRow = 2
endRow = nrow(single)
for(i in seq(startRow,endRow-1)){
  count = count + 1
  
  #calculation part
  calc(i,count)
  
  #action part
  #sell with stop and sell with trends
  if(sell(i,count)) next
  
  #buy
  buy(i,count)
}

getSummary(single,strategyStr )

write.table(single,paste("log/",strategyStr,".csv",sep=""))
sink()

getSummary(single,strategyStr )