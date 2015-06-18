#!/bin/bash
date=`date +%Y%m%d`
control=10
count=0
list=""
select=$1

if [ ! -d ./data/$date ]
then
    mkdir ./data/$date
fi

if [ -z $select ]
then
    echo "input sh or sz"
    exit 1
fi 

echo "start on $select"
echo "**************"
while read line
do 
    let count=count+1
    if [ $count -le $control ] 
    then
        list=$list",$select"$line
    else
        echo "downloading today data:$list"
        bash scripts/get_single_today.sh $select $list $date 
        list="$select"$line
        count=0
    fi
done < conf/${select}_list.conf
bash scripts/get_single_today.sh $select $list $date 


