######
# Description: ADD AWS EC2 EBS Volumes TAGs
#              Very simple script without variables, really ugly.. But work very nice...
#              Its only to document commands... 
# Author: charles.alandt(a)gmail.com
# Obs: Very ugly script... :D 
#
#
# 

#! /bin/bash

region='us-east-1'

### Change filters to select disks.... 

volume_ids=$( aws ec2 describe-volumes  --filters "Name=tag:Name,Values=Servers_PROD_*"  | jq -r '.Volumes[].VolumeId' ) 
#volume_ids=$(aws ec2 describe-volumes --region "${region}" --filters Name=volume-type,Values=gp2 | jq -r '.Volumes[].VolumeId'  )
#volume_ids=$(aws ec2 describe-volumes  --filters Name=tag:Name,Values=Servers_DEV_* | jq -r '.Volumes[].VolumeId' )

for volume_id in ${volume_ids};do
    echo -n  "Volume:  $volume_id - "
    aws ec2 create-tags --resource $volume_id  --tags 'Key=Team,Value=HELENAS_TEAM' 'Key=Sector,Value=SERVER_TI' 'Key=App,Value=SERVERS_SSS' 'Key=Application,Value=APPLICATIONS' 'Key=Environment,Value=production'
    if [ $? -eq 0 ] ;then
        echo "OK"
    else
        echo "ERROR"
    fi
    #read 
done

