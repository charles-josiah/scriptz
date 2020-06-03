#!/bin/bash
#Script de backup zimbra do agenda, tasks e contatos.
#Deve utilizar, zimbra_restore_agenda_tasks_contato.sh para restaurar os backups.
#

bkpCmd="zmmailbox"
dirBkp="./bkp"

dominio="dominio.com.br"

acao=getRestURL  #pru

for bkpCONTA in $(zmprov -l gaa | grep $dominio ) ; do 
      CONTA=`echo $bkpCONTA | awk -F'@' '{print $1}' `
			echo "Agenda..."
			$bkpCmd -z -m $bkpCONTA  $acao  "/Calendar/?fmt=ics" > $dirBkp/agenda-$CONTA.ics 
			echo "Tarefa..."
			$bkpCmd -z -m $bkpCONTA  $acao  "/Tasks"  >   $dirBkp/tasks-$CONTA.tsk
			echo "Contatos..."
			$bkpCmd -z -m $bkpCONTA  $acao  "/Contacts/?fmt=zip" >   $dirBkp/contatos-$CONTA.zip 
done




