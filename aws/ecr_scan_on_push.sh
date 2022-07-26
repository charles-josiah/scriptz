#!/bin/sh
REGION=us-east-1
REPO_LIST=$(aws ecr describe-repositories --query "repositories[].repositoryName" --output text --region $REGION);
for REPO in $REPO_LIST; do
    echo "set scan on push  for $REPO"
    aws ecr put-image-scanning-configuration --region $REGION --repository-name $REPO --image-scanning-configuration scanOnPush=true

done
