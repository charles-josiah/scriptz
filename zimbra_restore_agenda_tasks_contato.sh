#!/bin/bash
# Script de restauração dos arquivos de backup da agenda, tasks  e contatos do zimbra. Gerados pelo zimbra_bkp_agenda_tasks_contato.sh
# 


bkpCmd="zmmailbox"
dirBkp="./bkp"


for bkpCONTA in $(ls $dirBkp/*) ; do 

	CONTA=`echo $bkpCONTA | awk -F'-' '{print $2}' | sed 's/.\{4\}$//'  ` 
	echo -n "$CONTA - arq: $bkpCONTA -  " 
	case $bkpCONTA in
		*agenda* )
			echo "Agenda..."
			$bkpCmd -z -m $CONTA  pru /calendar?fmt=ics    $dirBkp/agenda-$CONTA.ics 
			;;
		*tasks* )
			echo "Tarefa..."
			$bkpCmd -z -m $CONTA  pru /Tasks    $dirBkp/tasks-$CONTA.tsk
			;;
		*contatos* )
			echo "Contatos..."
			$bkpCmd -z -m $CONTA  pru '/Contacts?fmt=zip&resolve=reset'  $dirBkp/contatos-$CONTA.zip 
			;;
		*)
			echo "Zicou"
			;;
		esac
done
