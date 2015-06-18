#PDC is yesterday close
trueFluc = function(H,L,PDC){
  return(max(max(H-L,H-PDC),PDC-L))
}

#the initial N = sum(TR)/20 last 20 days' average TR
#N is for measuring fluctuation
#N = ATR(20)
getN = function(H,L,PDC,PDN){
  return((19*PDN+trueFluc(H,L,PDC))/20)
}
#price is the stock priced
absoluteFluc = function(N,price){
  return(N*100*price)
}