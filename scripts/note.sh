##get all id
#awk '{len = length($0);print substr($0,len-5)}' rawdata/sh_name_id.raw > conf/sh_list.conf
#awk '{len = length($0);print substr($0,len-5)}' rawdata/sz_name_id.raw > conf/sz_list.conf

##get retry list
ls -l data/history | awk '{print $5"\t"$9}' | sort -k1nr | awk '{if($1<10000) print $2}' | sed 's/\.csv//g' | awk '{print substr($0,0,2)"\t"substr($0,3)}' > conf/retry_list.conf

