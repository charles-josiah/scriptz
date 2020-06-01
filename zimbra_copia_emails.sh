#/bin/bash
# Script de sincronização de servidores email Zimbra, ele mantem uma copia integra da caixa de email no novo servidor. 
# O script mantem sincronismo, ou seja, caso algum email seja removido na origem o mesmo será removido no novo servidor.

zmprovcmd="/opt/zimbra/bin/zmprov"


dominio="dom"
cmdSync=imapsync
servOrigem="ip_orin"
userOrigem="admin"
passOrigem="admin_senha"
servDest="ip_dest"
userDest="admin"
passDest="admin_senha"
LOG="./copia.log"
LOG_sync="./imapsync.log"

cont=0
totalEmail="`$zmprovcmd -l  gaa | grep  $dominio |  wc -l `"

echo "============================================= INICIANDO `date`==========================================" >> $LOG

for email in `$zmprovcmd -l  gaa | grep -v galsync |  grep -v spam | grep -v ham | grep -v virus  |   grep  $dominio ` 
do
   let cont++
   	echo "--- `date` - $cont/$totalEmail  - migracao: $email" >> $LOG

		$cmdSync  --buffersize 8192000 --nosyncacls --nofoldersizesatend  --subscribe --syncinternaldates \
			  --host1 $servOrigem  --user1 $email --ssl2 --authuser1 $userOrigem \
			  	  --password1 $passOrigem   --host2 $servDest  --user2 $email  --ssl2 --authuser2 $userDest  --password2 $passDest \
				  	  --sep2 / --regextrans2 s/Enviado/Sent/ --regextrans2 s/Rascunhos/Drafts/ --regextrans2 s/lixeira/Trash/ --regextrans2 s/Lixo\ Eletr\&APQ\-nico/Junk/ --delete2 --useuid  >> $LOG_sync 2>&1 


  	echo "" >> $LOG
	done


echo "============================================= FIM `date` ==========================================" >> $LOG
