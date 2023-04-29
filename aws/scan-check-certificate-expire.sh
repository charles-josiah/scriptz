#!/bin/bash
for a in `aws route53 list-hosted-zones-by-name | jq -r  ' .HostedZones | .[] | .Id' | cut -d'/' -f3 `; 
   do
      echo "------ $a ------"
   for b in ` aws route53 list-resource-record-sets --hosted-zone-id  "$a"  --query "ResourceRecordSets[?Type == 'A' || Type == 'CNAME'].Name"  --output text  `
      do
	 website="`echo ${b:: -1}`"
	 certificate_file=$(mktemp)

         timeout 1 bash -c " </dev/tcp/$website/443" 2>> /dev/null
      
         if [ $? == 0 ]; then
	    echo -n | openssl s_client -servername "$website" -connect "$website":443 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $certificate_file
	    date=$(openssl x509 -in $certificate_file -enddate -noout 2> /dev/null | sed "s/.*=\(.*\)/\1/")
	    date_s=$(date -d "${date}" +%s)
	    now_s=$(date -d now +%s)
	    date_diff=$(( (date_s - now_s) / 86400 ))
	    echo -n "$website expira em:  $date_diff dias "
	    if [ $date_diff -lt 20 ]; 
	        then 
	           echo "CUIDADO";
		else 
	           echo ""; 
		fi
	    else 
		echo "$website porta 443 fechada"
	    fi
      done
   done
