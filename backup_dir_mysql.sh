#!/bin/bash
#Script for backup some files and dirs, mysqld and send status to the telegram.

#diretorio de origem
dirParaBackup=" /etc /root /var/spool/cron /opt/  "

dataArq="`date +%Y%m%d`"

LOG="/var/log/backup-$dataArq.log"
tarLOG="/var/log/backup-tarlog-$dataArq.log"

userMysql="root"
passwdMysql="MINHASENHASEGURA"
cmdMysql="mysqldump"

cmdTelegram="/root/telegram.py"

servidor="`hostname`"

dirArqMysqlBkp="/home/springrunner/drive/Backup_dados/"
arqMysqBkp="$dataArq-BKP-$servidor-credenciamento-mysql.gz"

nomeArqComp="$dataArq-BKP-$servidor-credenciamento-arquivos.tar.gz" 
dirBackupComp="/home/springrunner/drive/Backup_dados/"

tarcmd="tar"
tarOpts="-zpcvf"

bkpTitle="BKP_MYSQL"
user_lnx="USERPARABACKUP" 
destdir="/home/DIRETORIOBACKUP/Backup_dados/"

inicio="`date +%Y%m%d' '%H%M%S`"

$cmdTelegram $bkpTitle "Inicio:  $inicio"

echo "INICIANDO BACKUP - servidor: $servidor - `date +%Y%m%d' '%H%M%S` " > $LOG
echo "================================================================================" >> $LOG
echo "Gerar dump do mysql "  >> $LOG
echo >> $LOG
echo "$cmdMysql  -u $userMysql  -p$passwdMysql  --all-databases \| gzip -9 > $dirArqMysqlBkp$arqMysqBkp" >> $LOG
$cmdMysql  -u $userMysql  -p$passwdMysql  --all-databases | gzip -9 >  $dirArqMysqlBkp$arqMysqBkp 
if [ $? -eq 0 ]; then 
  echo "Backup mysql [ OK ]" >> $LOG
  $cmdTelegram $bkpTitle  'MYSQL [ OK ]'
else
  echo "Backup mysql [ ERROR ]" >> $LOG
  $cmdTelegram $bkpTitle 'MYSQL [ NOK ]'
fi 
echo
echo "================================================================================" >> $LOG
echo "Gerando arquivo compactado" >> $LOG
echo "Compactando diretorio $dirParaBackup para $dirBackupComp$nomeArqComp" >> $LOG
echo "$tarcmd $tarOpts $dirBackupComp$nomeArqComp $dirParaBackup " >> $LOG
$tarcmd $tarOpts $dirBackupComp$nomeArqComp $dirParaBackup  >> $tarLOG  2>&1  
if [ $? -eq 0 ]; then
  echo "Backup Arquivos [ OK ]" >> $LOG
  $cmdTelegram $bkpTitle 'ARQUIVOS [ OK ]'
else
  echo "Backup Arquivos [ ERROR ]" >> $LOG
  $cmdTelegram $bkpTitle 'ARQUIVOS [ NOK ]' 
fi 

#echo "================================================================================" >> $LOG
#echo "Copiando as coisas para o lugar certo..." >> $LOG
#echo >> $LOG
#for a in " $dirArqMysqlBkp$arqMysqBkp $dirBackupComp$nomeArqComp "  ; do
#chown $user_lnx.$user_lnx $a >> $LOG
#echo "sudo -u $user_lnx  -s mv $a $destdir" >> $LOG
#sudo -u  $user_lnx -s mv  $a  "$destdir" >> $tarLOG  2>&1  
#if [ $? -eq 0 ]; then
#  echo "Copia Arquivos - $a [ OK ]" >> $LOG
#  $cmdTelegram $bkpTitle 'Copia Arquivos - '"$a"' [ OK ]'
#else
#  echo "Copia Arquivos - $a [ ERROR ]" >> $LOG
#  $cmdTelegram $bkpTitle 'Copia Arquivos - '"$a"' [ NOK ]'
#fi
#done

 $cmdTelegram $bkpTitle  "Fim: `date +%Y%m%d' '%H%M%S`"


echo "================================================================================" >> $LOG
echo "FINALIZADO BACKUP - servidor: $servidor - `date +%Y%m%d' '%H%M%S` " >> $LOG
echo "================================================================================" >> $LOG
#
