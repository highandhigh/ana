#!/bin/bash

type=$1
id=$2
url="http://table.finance.yahoo.com/table.csv?s=${id}.${type}"
res=`curl $url > data/history/$type$id.csv`
echo $res
