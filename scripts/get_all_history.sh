#!/bin/bash

echo "start on SH"
echo "**************"
while read line
do 
    echo "downloading history data:$line"
    sh scripts/get_single_history.sh ss $line    
done < conf/ss_list.conf

echo "start on SZ"
echo "**************"
while read line
do 
    echo "downloading history data:$line"
    sh scripts/get_single_history.sh sz $line
done < conf/sz_list.conf

