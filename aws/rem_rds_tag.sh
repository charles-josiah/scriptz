 
######
# Description: Remove all AWS RDS TAGs on CSV format
# Author: charles.alandt(a)gmail.com
# Obs: Very ugly script... :D 
#

#!/bin/bash
ARNS=$(aws rds describe-db-instances --query "DBInstances[].DBInstanceArn"  | jq -r ' .[]' | grep $1)
for line in $ARNS; do
    #NAME=$(aws rds describe-db-instances --query "DBInstances[?DBInstanceArn=='$line']" | jq -r  " .[] | .DBInstanceIdentifier ")
    for TAGS in $(aws rds list-tags-for-resource --resource-name "$line" --query "TagList[]"  | jq  -r  '.[] | .Key   ')
    do
                    #echo "$line; $TAGS"  
                    echo "aws rds remove-tags-from-resource --resource-name '$line' --tag-keys $TAGS"
        done
done
