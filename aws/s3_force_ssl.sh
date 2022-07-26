#!/bin/bash
#
# https://www.nicks.io/forcing-ssl-on-all-s3-buckets/
#

buckets=`aws s3api list-buckets | jq -r '.Buckets[].Name'`

for bucket in $buckets
do
    echo "$bucket"
    if aws s3api get-bucket-policy --bucket $bucket --query Policy --output text &> /dev/null; then
        size=`aws s3api get-bucket-policy --bucket $bucket --query Policy --output text | jq -r 'select(.Statement[].Condition.Bool."aws:SecureTransport"=="false")' | wc | awk {'print $1'}`
        
        if [ $size == 0 ]; then 
            echo "Appending Policy to $bucket"
            aws s3api put-bucket-policy --bucket $bucket --policy "$(aws s3api get-bucket-policy --bucket $bucket --query Policy --output text | jq --arg bucket "$bucket" '.Statement += [{"Sid":"AllowSSLRequestsOnly","Action":"s3:*","Effect":"Deny","Resource":["arn:aws:s3:::" + $bucket + "","arn:aws:s3:::" + $bucket + "/*"],"Condition":{"Bool":{"aws:SecureTransport":"false"}},"Principal":"*"}]')"
        fi
    else
        echo "Creating Policy for $bucket"
        #echo '{"Id":"ExamplePolicy","Version":"2012-10-17","Statement":[{"Sid":"AllowSSLRequestsOnly","Action":"s3:*","Effect":"Deny","Resource":["arn:aws:s3:::'"$bucket"'","arn:aws:s3:::'"$bucket"'/*"],"Condition":{"Bool":{"aws:SecureTransport":"false"}},"Principal":"*"}]}'
        aws s3api put-bucket-policy --bucket $bucket --policy '{"Id":"ExamplePolicy","Version":"2012-10-17","Statement":[{"Sid":"AllowSSLRequestsOnly","Action":"s3:*","Effect":"Deny","Resource":["arn:aws:s3:::'"$bucket"'","arn:aws:s3:::'"$bucket"'/*"],"Condition":{"Bool":{"aws:SecureTransport":"false"}},"Principal":"*"}]}'
    fi
done

