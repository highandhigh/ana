#!/bin/bash
bash scripts/get_all_today.sh sh
echo "sh daily data download completed"

bash scripts/get_all_today.sh sz
echo "sz daily data download completed"

# insert into mongo db
R -f r/importDaily.R 
