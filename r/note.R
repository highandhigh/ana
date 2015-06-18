install.packages("quantmod")
library(quantmod)
setSymbolLookup(HLSN=list(name="600319.ss",src="yahoo", from="2005-07-10",to="2014-07-18"))
getSymbols("HLSN")
HLSN

install.packages("rmongodb",repos = "http://mirror.bjtu.edu.cn/cran/")

#db.stocks.createIndex({"id":1,"Date":1},{unique:true})