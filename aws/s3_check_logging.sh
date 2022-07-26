#!/bin/bash -e

# Get list of buckets
S3_BUCKETS=( `aws s3api list-buckets --query "Buckets[].Name" --output=text` )

for bucket in "${S3_BUCKETS[@]}"; do
   BUCKET_LOGGING=`aws s3api get-bucket-logging --bucket $bucket`
   if [ -n "$BUCKET_LOGGING" ]; then
      echo "$bucket: $BUCKET_LOGGING"
   fi
done
