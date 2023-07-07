#!bin/bash
#Finding and Releasing Unattached Elastic IPs via AWS CLI
#First Review: 2023/07/06
#PS: Very lazy and ugly script... Please do better than this... :D 
#PS1: Don't forget to export your temporary keys or use a cloudshell
#------------------------------

echo "Thanks everone to wathching...."
echo "Finding and Releasing Unattached Elastic IPs via AWS CLI"
echo "we use aws cloud shell to be easier... and I am very lazy today :D"
echo "First, don't forget do export your keys and region" 
echo "let's go..." 

aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --query "Addresses[?AssociationId==null]" 

echo "nice, found someone"
echo "but only us-east-1, lets expand this "
echo "lets find List All Enabled Regions Within An AWS account"

aws ec2 describe-regions --all-regions | jq -r '.Regions | .[] | .RegionName + " " + .OptInStatus'  | grep -v not-opted-in | cut -d' ' -f1

echo "nice, lets put all together" 

for a in `aws ec2 describe-regions --all-regions | jq -r '.Regions | .[] | .RegionName + " " + .OptInStatus'  | grep -v not-opted-in | cut -d' ' -f1`; do echo "--- $a ---"; aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --query "Addresses[?AssociationId==null]" --region $a ; done

echo "hummm, very nice, we have a big list, in a  ugly script"
echo "to release them..." 

aws ec2 release-address  --allocation-id 

echo "improving..." 

for a in `aws ec2 describe-regions --all-regions | jq -r '.Regions | .[] | .RegionName + " " + .OptInStatus'  | grep -v not-opted-in | cut -d' ' -f1`; do echo "--- $a ---"; aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --query "Addresses[?AssociationId==null]" --region $a  | jq -r  .[].AllocationId ; done

echo "more and more improving... in a  ugly script" 

for a in `aws ec2 describe-regions --all-regions | jq -r '.Regions | .[] | .RegionName + " " + .OptInStatus'  | grep -v not-opted-in | cut -d' ' -f1`; do echo "--- $a ---"; for b in `aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --query "Addresses[?AssociationId==null]" --region $a  | jq -r  .[].AllocationId`; do echo "releasing: $b"; aws ec2 release-address  --allocation-id $b --region $a ; done ; done

echo "running again to check" 

for a in `aws ec2 describe-regions --all-regions | jq -r '.Regions | .[] | .RegionName + " " + .OptInStatus'  | grep -v not-opted-in | cut -d' ' -f1`; do echo "--- $a ---"; aws ec2 describe-addresses --filters "Name=domain,Values=vpc" --query "Addresses[?AssociationId==null]" --region $a ; done

echo "uhuuuu.... No more lost EIP on my account... "   
echo "Its all ok for now :D "
echo "nice....  Bye bye folks  :D "
echo "don't forget to follow-me and give me some likes..  "
echo "and share this video..."
echo "bye, bye"


