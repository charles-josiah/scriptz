#!/bin/bash
#Backup Servidores Firewall 
#Script não é bonito, é tosco, simples, porem altamente funcional.  :D 
#O script faz "coisarada" porem quando for usar, precisa ajustar as coisas.... 
#
#Segue lista de observações: 
#--- suportava backup para fita porem foi desabilitado :(
#--- caso usar disco externo, unidades DELL RDXXXX ou HD Externo, nomear os mesmos com e2label
#--- suporta sincronismo de pastas para locais remotos, salvando o permissionamento com getfacl
#--- Backup incremental semanal, gerando 1 full toda a quinta.
#--- Gera um backup full no primeiro dia do mes.
#--- Validar diretorios que não devem entrar no tar, na linha 91, $tarcmd $tarOpts $dirBackup.......
#--- copia backups gerados pelo oracle no diretorio /oracle/backup/*  
#--- ajustar email para envio do status final


#diretorio de origem
#dirParaBackup="/usr/local/ /var/www/ /etc /var/spool/cron /boot/grub/menu.lst /boot /home /root  "
dirParaBackup="/home /etc /root /var/spool/cron"

dirSync=(/home /etc /root)
dirSyncDest="/mnt/backup/"

#diretorio de destino
dirBackupComp="/home/backup/backupuniversal/"

servidor=`hostname`
rsyncOpts=" -ravzpt  --stats" # usar --delete
rsyncmd="rsync"
tarcmd="tar"
tarOpts="-g $dirBackupComp/contr-$servidor.txt  -zpcvf"

dataArq="`date +%Y%m%d`"

iptSave="/sbin/iptables-save"
iptArq="/etc/MT/$dataArq-$servidor-iptables.txt"

routeCmd="route -n"
routeArq="/etc/MT/$servidor-rotas-`date +%Y%m%d`"

servidorEmail="smtp.interno.local"
emailDestino="XXXXXX@XXXXXX.com.br"
emailTitulo="MT -  BACKUP - $servidor"
emailCorpo="Backup realizado do $servidor.\nVerificar arquivo anexo com log.\n\nObrigado"  
LOG="/var/log/backup-$servidor-`date +%Y%m%d`.log"

case `date +%a` in
	Mon|mon|Seg) diaSemana="Seg";;
	Tue|tue|Ter) diaSemana="Ter";;
	Wed|wed|Qua) diaSemana="Qua";;
	Thu|thu|Qui) diaSemana="Qui";;
	Fri|fri|sex) diaSemana="Sex";;
	Sat|sat|Sab) diaSemana="Sab";;
	Sun|sun|Dom) diaSemana="Dom";;
	*)	diaSemana="naosei";;
esac

if [  `date +%d` = 01 ];
	then
		echo "Chegou a hora... Primeiro dia do mes... Backup FULL" >> $LOG
		diaSemana="Dom";
		nomeArqComp="BKP-$servidor-FULL-`date +%m`.tar.gz"
	else
		echo "Nao e o dia primeiro ainda" >> $LOG
		nomeArqComp="BKP-$servidor-$diaSemana.tar.gz"
	fi

echo "INICIANDO BACKUP - servidor: $servidor - `date +%Y%m%d' '%H%M%S` " > $LOG
echo "INICIANDO BACKUP - servidor: $servidor - `date +%Y%m%d' '%H%M%S` "  >> $dirSyncDest/$dataArq.bkp.txt  
echo "================================================================================" >> $LOG
if [ ! -d "/etc/MT" ]; 
	then
   		mkdir -p /etc/MT 2>&1  >> $LOG
   		echo "Criando diretorio /etc/MT" >> $LOG
   	else
		echo "Diretorio ja existe:  /etc/MT" >> $LOG
fi
echo "================================================================================" >> $LOG
echo "Gerar dump do iptables"  >> $LOG
echo "`$iptSave`"   > $iptArq
echo "Salva tabela roteamento" >> $LOG
echo "`$routeCmd`" > $routeArq
echo "================================================================================" >> $LOG
echo "Gerar arquivo de backup full ? Dia da semana: $diaSemana"  >> $LOG
case $diaSemana in
	"Dom")  echo "Chegou a hora..." >> $LOG
		rm -f $dirBackupComp/contr-$servidor.txt 2>&1  >> $LOG 
                echo "Resultado: $?" >> LOG 
		;; 
	*)	echo "Nao chegou a hora ainda..."  2>&1 >> $LOG ;;
esac

echo "================================================================================" >> $LOG
echo "Gerando arquivo compactado" >> $LOG
echo "Compactando diretorio $dirParaBackup para $dirBackupComp/$nomeArqComp" >> $LOG
echo "$tarcmd $tarOpts $dirBackupComp$nomeArqComp $dirParaBackup  --exclude=$dirBackupComp/*  --exclude=/home/tmp/* --exclude=/home/informatica/* --exclude=/home/instaladores/* --exclude=/home/arquivos/*  --exclude=/home/bkp/*  " >> $LOG
$tarcmd $tarOpts $dirBackupComp/$nomeArqComp $dirParaBackup --exclude="$dirBackupComp*"    2>&1 >> $LOG
echo "================================================================================" >> $LOG
echo "Sincronizando com o fileserver" >> $LOG
for dir in "${dirSync[@]}" 
   do
     echo "$dataArq - Sinc INICIO:  $dir" >> $LOG 
     rsync  -ravp  --delete --progress --exclude 'backup/*' $dir/  /$dirSyncDest/$dir/    2>&1 >> $LOG	
     echo "$dataArq - Sinc FIM" >> $LOG
     echo "Permissionamento...." >> $LOG
     getfacl -R $dir/ >  /$dirSyncDest/$dir/$dataArq.acl.files.txt

     for t in files links directories; do echo `find $dir/  -type ${t:0:1} | wc -l` $t; done 2> /dev/null >> /$dirSyncDest/$dataArq.bkp.txt


done

echo "================================================================================" >> $LOG
echo "FINALIZADO BACKUP - servidor: $servidor - `date +%Y%m%d' '%H%M%S` " >> $LOG
echo "FINALIZADO BACKUP - servidor: $servidor - `date +%Y%m%d' '%H%M%S` " >> /$dirSyncDest/$dataArq.bkp.txt
echo "================================================================================" >> $LOG

#echo "Montando FITA" >> $LOG
#umount /mnt/TAPE  >>  $LOG
#mount -L backup_tape /mnt/TAPE/ >>  $LOG
#if [ $? -eq 0 ]
#        then
#		echo "Copiando o arquivo de controle e $nomeArqComp" >> $LOG
#	 	mkdir -p /mnt/TAPE/$dirBackupComp/	
#		cp -f $dirBackupComp/contr.txt /mnt/TAPE/$dirBackupComp/  2>&1 >>  $LOG 
#		cp  -f $dirBackupComp/$nomeArqComp /mnt/TAPE/$dirBackupComp/ 2>&1 >> $LOG
#                echo "Mensagem: $? " >> $LOG
#		echo "Iniciando rsync para DR1000: $(date +%Y-%m-%d-%k:%m)" >> $LOG
#		rsync -Cravzp --delete --progress  /oracle/backup/*  /mnt/TAPE/   >> $LOG
#                umount /mnt/TAPE >> $LOG
#                umount /mnt/TAPE >> $LOG
#                echo "Mensagem: $? ">> $LOG
#                if [ "$diaSemana" == "Dom" ]; 
#			then  
#				echo "NAO EJETAR FITA"  2>&1 >> $LOG
#			else
#                		echo "Ejetando fita... ">> $LOG
#	               		eject -v  backup_tape  >> $LOG
#		fi
#       # else
#                echo "FITA NAO ENCONTRADA" >> $LOG
#        fi


echo "Enviando email..." >> $LOG
sendEmail.pl -t $emailDestino -u "$emailTitulo" -m $emailCorpo -a $LOG  -f $emailDestino -s $servidorEmail 2>&1 >> $LOG
echo "================================================================================" >> $LOG

