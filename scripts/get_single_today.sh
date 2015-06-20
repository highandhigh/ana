#!/bin/bash
type=$1
idList=$2
date=$3
url="http://hq.sinajs.cn/list=$idList"
res=`curl $url >> rawdata/$date/${type}_data.csv`
echo $res
