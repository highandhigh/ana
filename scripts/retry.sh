#!/bin/bash
count=0
t=$1
echo "**************"
while read line
do 
    let count=count+1
    if [ $count -ge $t ] 
    then 
       exit 0
    fi
    echo "downloading history data:$line"
    sh scripts/get_single_history.sh $line    
done < conf/retry_list.conf

