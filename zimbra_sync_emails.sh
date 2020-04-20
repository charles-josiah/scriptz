######
# Script para sincronização de contas entre 2 zimbra. 
# Mantem os emails sincronizados entre a conta do servidor zimbra 1 e servidor zimbra 2
# Ex. o que foi excluido de um lado é excluido do outro servidor.
# Adicionar na cron, caso deseje sincronizar continuamente.
#
# Script to synchronize accounts between 2 zimbra.
# Keeps emails synchronized between the zimbra 1 server account and zimbra 2 server
# Ex. What was excluded on one side is excluded on the other.
# Add to cron, if you want to synchronize continuously.
#
# Ultimo update: 2020/04/20
#
zmprovcmd="/opt/zimbra/bin/zmprov"


dominio="<domino>"
cmdSync=imapsync
servOrigem="<ip serv origem>"
userOrigem="<zimbra admin>"
passOrigem="<zimbra admin pass>"
servDest="<ip serv destino>"
userDest="<usuario zimbra admin destino>"
passDest="<zimbra admin pass destino>"
LOG="./copia.log"           #onde vai os logs do script
LOG_sync="./imapsync.log"   #onde vai os imapsync

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
				  	  --sep2 / --regextrans2 s/Enviado/Sent/ --regextrans2 s/Rascunhos/Drafts/ --regextrans2 s/lixeira/Trash/ --regextrans2 s/Lixo\ Eletr\&APQ\-nico/Junk/ --delete2 --useuid --exclude '(?i)\b(|Emailed \Contacts|Contacts)\b'  >> $LOG_sync 2>&1 
  	echo "" >> $LOG
	done


echo "============================================= FIM `date` ==========================================" >> $LOG
