######
# Description: ADD AWS RDS TAGs
# Author: charles.alandt(a)gmail.com
# Obs: Very ugly script... :D 
#


#!/bin/bash

sector=SETOR
environment=AMBIENTE_PROD
team=TIME_ENVOLVIDO
app=APLICACAO


TAGS='"[{\"Key\": \"sector\",\"Value\": \"'$sector'\"},{\"Key\": \"environment\",\"Value\": \"'$environment'\"},{\"Key\": \"team\",\"Value\": \"'$team'\"},{\"Key\": \"application\",\"Value\": \"'$app'\"}]"'

ARNS=$(aws rds describe-db-instances --query "DBInstances[].DBInstanceArn"  | jq -r ' .[]' | grep $1)
for line in $ARNS; do
   echo " aws rds add-tags-to-resource --resource-name '$line' --tags $TAGS    "
done
