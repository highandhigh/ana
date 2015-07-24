#strategy setup
#strategyStr = "20and50StrFunc"
#strategyStr = "20and50StrFunc2"
#strategyStr = "20LT50StrFunc"
strategyStr = "20LT50All"
#strategyStr = "20LT50StrFunc3"
#strategyStr = "atrFunc"
#strategyStr = "atrFunc2"
#strategyStr="BollingerFunc"
#strategyStr="Donchian"
source(paste("strategy/",strategyStr,".R",sep=""))
source("r/metrics.R")
source("r/turtleFunc.R")

#init
startDate = as.Date("2001-05-07")
count = 0
share = 0
moneyleft = moneytotal
allData$share = 0
allData$moneyleft = 0
allData$profit = 0
hold = c()
record = data.frame()

logFile = paste("log/",strategyStr,".log",sep="")
file.remove(logFile)
#sink(logFile)

#df.subsets <- split(df,year(as.Date(df$V2, "%Y-%m-%d")))

#for(i in seq(1,5157)){
for(i in seq(1,60)){
  dayData = subset(allData,as.character(allData$Date) == as.character(startDate + i) )
  print(paste("Handling date:",startDate+i,sep=""))
  if(nrow(dayData) <= 800){
    print("Should be some holiday, continue")
    next
  }
  #action part
  #sell with stop and sell with trends
  sell(dayData)
  
  #buy
  buy(dayData)
}
getSummary(single,strategyStr )

write.table(single,paste("log/",strategyStr,".csv",sep=""))
sink()

getSummary(single,strategyStr )