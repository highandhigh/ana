#install.packages("quantmod")
#install.packages("lubridate")
#setSymbolLookup(HLSN=list(name="600319.ss",src="yahoo", from="2005-07-10",to="2014-07-18"))
#getSymbols("HLSN")
#HLSN

#install.packages("rmongodb",repos = "http://mirror.bjtu.edu.cn/cran/")
#install.packages("ggplot2")
#db.stocks.createIndex({"id":1,"Date":1},{unique:true})
#http://ichart.yahoo.com/table.csv?s=600433.SS&a=08&b=25&c=2010&d=09&e=8&f=2013&g=v

#how to deal with stop data

#awk -F',' '{print substr($1,12,8)","$2","$4","$5","$6","$9}' 20150617/sh_data.csv 

allStock = read.table("test.csv",header = TRUE,sep="," )
backup = allStock
allStock = subset(allStock,allStock$Volume > 0)
allStock$Date  = as.Date(allStock$Date,format= "%Y-%m-%d")
allData$Date = as.Date(allData$Date,format= "%Y-%m-%d")
allData = read.table("allData.csv",header = TRUE,sep="," )
single = subset(allData,id =="600862")
