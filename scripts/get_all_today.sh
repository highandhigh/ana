#!/bin/bash
date=`date +%Y%m%d`
control=10
count=0
list=""
select=$1

if [ ! -d ./rawdata/$date ]
then
    mkdir ./rawdata/$date
fi

if [ ! -d ./data/$date ]
then
    mkdir ./data/$date
fi

if [ -z $select ] 
then
    echo "input sh or sz"
    exit 1
fi 

if [ ! -z $2 ]
then
    echo "date set to $2"
    date=$2
fi
#clean the data before downloading 
rm ./rawdata/$date/${select}*.csv
rm ./data/$date/${select}*.csv

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
	t=$(($RANDOM%10+1))
        sleep $t
        list="$select"$line
        count=0
    fi
done < conf/${select}_list.conf
bash scripts/get_single_today.sh $select $list $date 

echo "id,Open,Close,High,Low,Volume" > data/${date}/${select}_data.csv
awk '{if(length($0)>50) print $0}' rawdata/${date}/${select}_data.csv | awk -F',' '{print substr($1,12,8)","$2","$4","$5","$6","$9}'  >> data/${date}/${select}_data.csv

