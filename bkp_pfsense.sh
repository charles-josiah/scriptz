#!/bin/bash
## script gambi para backup de um cluster pfsense utilizando CARP, porem funciona para 1 unico servidor.
## Backup baseado no cookie salvo do site, procedimento descrito:
## https://www.netgate.com/docs/pfsense/backup/remote-config-backup.html
## 
## Recomendado criar usuario com baixo nivel de permissionamento, ou "fechar" o escopo so para backup do appliance.

arquivo=/bkp/pfsense/backup-`date +%Y%m%d%H%M` #diretorio destino
login=bkp #usuario
senha=XXXXXXX #senha
porta=8443 #porta de gerencia


for i in "<IP MASTER>" "<IP SLAVE>"
do
	echo "Backup servidor: $i";
	wget -qO/dev/null --keep-session-cookies --save-cookies cookies.txt --post-data "login=Login&usernamefld=$login&passwordfld=$senha" --no-check-certificate https://$i:$porta/diag_backup.php
	wget --keep-session-cookies --load-cookies cookies.txt --post-data 'Submit=download&donotbackuprrd=yes' https://$i:$porta/diag_backup.php  --no-check-certificate -O $arquivo-$i.xml 
	gzip -9f $arquivo-$i.xml
done
