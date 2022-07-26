#!/bin/sh
REGION=us-west-2
REPO_LIST=$(aws ecr describe-repositories --query "repositories[].repositoryName" --output text --region $REGION);
for REPO in $REPO_LIST; do
    echo "set immutable for $REPO"
    aws ecr put-image-tag-mutability --repository-name $REPO  --image-tag-mutability IMMUTABLE --region $REGION


done
