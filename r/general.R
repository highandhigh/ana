setwd("/Users/yshan/dev/ana/")
library(stringr)

#unifile the ss -> sh
uniType = function(type){
  return(str_replace_all(type,"ss","sh"))
}
