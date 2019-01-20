#!/bin/bash
# 
# Mais um script de backup do PFSENSE
# Baseado na documentacao: https://www.netgate.com/docs/pfsense/backup/remote-config-backup.html 
# Base do script hfaria, no link: http://www.bacula.com.br/pre-script-para-backup-de-firewall-pfsense-232/
# Integração telegram: https://github.com/GabrielRF/Zabbix-Telegram-Notification
#
# Ultimas alterações é integração com o Telegram para envio de mensagem do status de backup e um array para multiplos servidores na rede.
# 
#
# Melhorais por Charles Josiah, Data: 01/07/2018
######
#
#

USER=backup                                       #usuario backup
PASSWORD='S3nh@M@luc0nA.!@#$'                     #senha do usuario backup
DIR_BKP="./bkp"

data="`date +%Y%m%d%H%M`"

porta="8443"                                      #Porta do pfsense

#HOSTS para backup
HOST[0]="192.168.0.254"
HOST[1]="192.168.2.254"
HOST[2]="192.168.4.254"
HOST[3]="192.168.6.254"
#HOST[x]="x.x.x.x".... e assim vai

if [ ! -d "$DIR_BKP" ]; then
	 mkdir -p $DIR_BKP
fi


######################
x=0;
while [ $x != ${#HOST[@]} ]
    do
	 echo "--- $data Iniciando bkp config.xml ${HOST[$x]} --- "
	   
	 wget -qO- --keep-session-cookies --save-cookies $DIR_BKP/cookies.txt  --no-check-certificate https://${HOST[$x]}:$porta/diag_backup.php | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > $DIR_BKP/csrf.txt && cat $DIR_BKP/csrf.txt

	 wget -qO- --keep-session-cookies --load-cookies $DIR_BKP/cookies.txt --save-cookies $DIR_BKP/cookies.txt --no-check-certificate --post-data "login=Login&usernamefld=$USER&$PASSWORDfld=pfsense&__csrf_magic=$(cat $DIR_BKP/csrf.txt)" https://${HOST[$x]}:$porta/diag_backup.php  | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > $DIR_BKP/csrf2.txt && cat $DIR_BKP/csrf2.txt

	 wget --keep-session-cookies --load-cookies $DIR_BKP/cookies.txt --no-check-certificate  --post-data "Submit=download&donotbackuprrd=yes&__csrf_magic=$(head -n 1 $DIR_BKP/csrf2.txt)"  https://${HOST[$x]}:$porta/diag_backup.php -O $DIR_BKP/$data-${HOST[$x]}-config.xml
	   
	 STATUS=$(echo $?)
	    
	 if [[ $STATUS == 0 ]]; then 
	 	echo "BKP realizdo com sucesso, compactando"
		telegram.py "MT-BKP" "Backup ${HOST[$x]}  PFSENSE OK " 
			gzip -9v $DIR_BKP/$data-${HOST[$x]}-config.xml 
	    else
	        echo "BKP COM ERRO "
	        ERRO=1
  	 fi
	 let "x = x +1"
done
if [[ $ERRO == 1 ]]; then
     echo "Erro na execucao, exit 1"
     telegram.py "MT-BKP" "Backup ${HOST[$x]}  PFSENSE ERRO " 
    exit 1
fi
