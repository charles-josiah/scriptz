######
# Description: Show all AWS RDS TAGs on CSV format
# Author: charles.alandt(a)gmail.com
# Obs: Very ugly script... :D 
#

#!/bin/bash
ARNS=$(aws rds describe-db-instances --query "DBInstances[].DBInstanceArn"  | jq -r ' .[]' )
for line in $ARNS; do
    NAME=$(aws rds describe-db-instances --query "DBInstances[?DBInstanceArn=='$line']   " | jq -r  " .[] | .DBInstanceIdentifier ")
    TAGS=$(aws rds list-tags-for-resource --resource-name "$line" --query "TagList[]  "  | jq  -j '.[] | [.Key+":"+.Value+"; "] | @tsv  ')
    echo "$NAME; $TAGS"   
done
