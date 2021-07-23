######
# Description: Another script to change EC2 disks from gp2 to gp3
# Author: charles.alandt(a)gmail.com
# Obs: Yes, is a very ugly script... :D 
#


#! /bin/bash

region='us-east-1'

#volume_ids=$(aws ec2 describe-volumes --region "${region}" --filters Name=volume-type,Values=gp2 | jq -r '.Volumes[].VolumeId'  )

#Anothers filters, with machines names and volumes-types...
#volume_ids=$(aws ec2 describe-volumes  --filters "Name=tag:Name,Values=MACHINE_PROD_*" "Name=volume-type,Values=gp2" | jq -r '.Volumes[].VolumeId' )
#volume_ids=$(aws ec2 describe-volumes  --filters "Name=tag:Name,Values=ANOTHER_PROD_*" "Name=volume-type,Values=standard"  | jq -r '.Volumes[].VolumeId' ) 

for volume_id in ${volume_ids};do
    echo -n "Volume:  $volume_id - "
    result=$(aws ec2 modify-volume --region "${region}" --volume-type=gp3 --volume-id "${volume_id}" | jq '.VolumeModification.ModificationState' | sed 's/"//g')
    if [ $? -eq 0 ] && [ "${result}" == "modifying" ];then
        echo "OK"
    else
        echo "ERROR: cannot change to gp3!"
    fi
done
