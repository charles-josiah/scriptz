#!/bin/bash
# Script de restauração dos arquivos de backup da agenda, tasks  e contatos do zimbra. Gerados pelo zimbra_bkp_agenda_tasks_contato.sh
# Script sem data definida de criação... :D 


bkpCmd="zmmailbox"
dirBkp="./bkp"
dominio="dominio.com.br"



for bkpCONTA in $(ls $dirBkp/*) ; do 

	CONTA=`echo $bkpCONTA | awk -F'-' '{print $2}' | sed 's/.\{4\}$//'  ` 
	echo -n "$CONTA@$dominio - arq: $bkpCONTA -  " 
	case $bkpCONTA in
		*agenda* )
			echo "Agenda..."
			$bkpCmd -z -m $CONTA@$dominio  pru /calendar?fmt=ics    $dirBkp/agenda-$CONTA.ics 
			;;
		*tasks* )
			echo "Tarefa..."
			$bkpCmd -z -m $CONTA@$dominio  pru /Tasks    $dirBkp/tasks-$CONTA.tsk
			;;
		*contatos* )
			echo "Contatos..."
			$bkpCmd -z -m $CONTA@$dominio  pru '/Contacts?fmt=zip&resolve=reset'  $dirBkp/contatos-$CONTA.zip 
			;;
		*)
			echo "Zicou"
			;;
		esac
done
