printAllStock = function(hold,df){
  for(i in hold){
    print(df[i,])
  }
}

getYearPlot = function(year){
  ss = subset(single,single$Date < as.Date(paste("200",year+1,"-01-01",sep=""),"%Y-%m-%d") & 
                single$Date >= as.Date(paste("200",year,"-01-01",sep=""),"%Y-%m-%d"))
  plot(ss$Date,ss$Close,main = paste("year:200",year,sep=""),type = "l")
  points(ss$Date,ss[,highStr],col="red",pch=4)
  points(ss$Date,ss[,lowStr],col ="blue",pch=20)
}

getYearPlotAtr = function(year){
  ss = subset(single,  as.character(single$Date,"%Y") ==  as.character(year))
  plot(ss$Date,ss$Close,main = paste("year:",year,sep=""),type = "l",ylim = range(0,max(ss$Close)+1))
  points(ss$Date,ss[,closeStr]+7*ss[,"N"],col="red",pch=4)
  points(ss$Date,ss[,closeStr]-3*ss[,"N"],col ="blue",pch=20)
}

getYearPlotBoll= function(year){
  ss = subset(single,  as.character(single$Date,"%Y") ==  as.character(year))
  plot(ss$Date,ss$Close,main = paste("year:",year,sep=""),type = "l",ylim = range(0,max(ss$Close)+5))
  points(ss$Date,ss[,closeStr]+2.5*ss[,sdStr],col="red",pch=4)
  points(ss$Date,ss[,closeStr]-2.5*ss[,sdStr],col ="blue",pch=20)
}
