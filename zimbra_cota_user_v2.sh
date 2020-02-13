#
# Script que gera um CSV dos usuario de um dominio no Zimbra, informações no formato: 
# email;DisplayName;Cota;Uso;Status
# No final mostra o tamanho total em Mb de todas as contas do dominio.
# 
# 13/01/2018, by Charles Josiah, <charles.alandt at gmail.com>
#  - Versão inicial
# 13/02/2020, By Charles Josiah, <charles.alandt at gmail.com>
#  - Melhoramentos da versão, 
#    - alerta via email e MTMON (monitoramento Multitask) das cotas acima do tamanho pre-estabelecido.
#    - lista dos emails, com o percentual da cota utilizada 
#    - controle de execução do script, não permitindo que seja executado mais de um simultaneamente
      
dominio="<dominio>"
servidor="`/opt/zimbra/bin/zmhostname`"

total=0
cmdZM="/opt/zimbra/bin/zmprov"
limiteAlerta=98
listaUsers="/opt/zimbra/scriptz/listaUsuario.txt"
avisar=1
email="<email que sera enviado email>"
cmd_email="/usr/sbin/sendmail"
mtmon=" /usr/local/bin/mtmon_evento.pl --repete --aplicacao ZIMBRA --eventual --severidade 2 --Mensagem "
user=0
userCota=0
crtl="/opt/zimbra/scriptz/crtl"

function gera_lista { 

	all_accounts=` /opt/zimbra/bin/zmprov  gqu $servidor |  grep $dominio | grep -v virus-quarantine | tr " " ";" `
	for a in $all_accounts;do 
		e=`echo $a | awk -F";" '{print $3 }' ` #cota usada
		f=`echo $a | awk -F";" '{print $1 }' ` #nome da conta
	  g=`echo $a | awk -F";" '{print $2 }' ` #cota total
	  status=`$cmdZM ga $f  zimbraAccountStatus  | grep zimbraAccountStatus: | awk '{ print $2 }' ` 
	  displayName=`$cmdZM ga $f displayName  | grep displayName: | awk '{ print $2 }' ` 

	  echo -n "$f;$displayName"
	  echo -n ";`echo "scale=2; ${e}/1024/1024" | bc`"   #cota total - divide para chegar em MB
	  echo -n ";`echo "scale=2; ${g}/1024/1024" | bc`"   #usado usuario - divide para chegar em MB
	 
	  porcent=$((100*${e}/${g}))   

	  if [  "$porcent"  -gt "$limiteAlerta" ]; 
		then 
		   echo -n "; cota estourada precisa avisar alguem"; 
		   echo "$f;$displayName;$porcent%" >> $listaUsers
		   let userCota=$userCota+1
	  fi
	  
	  echo -n ";$porcent%";
	  echo -n ";$status;"
	  echo ""
	  let total=$total+$e
	  let user=$user+1
	done 

} 

function avisar 
{ 
	echo ""
	echo -n "Aviso alguem ?" 
	if [ "$avisar" -eq "1" ];
	   then
	     echo "Sim"
		 $cmd_email $email  < $listaUsers
		 echo "Status do envio: $?"
		 $mtmon "Usuarios com cota acima de $limiteAlerta% " --dump <$listaUsers 
		 echo "Status do MTMON: $?"
	   else 
	   	echo "Nao, se precisar ajustar a variavel..."
	fi
}

function estat { 
	echo "" 
	echo "" 
	echo "----------------------------------------------------" 
	echo "Estatisticas " 
	echo "Iniciado: $dt " 
	echo "Finalizado: `date +%Y%m%d"_"%H%M%S` " 
	echo "Usuarios: $user "
	echo "Overcota: $userCota " 
	echo "Armazenamento Total usado: `echo  ${total}/1024/1024 | bc` Mb " 
	echo "----------------------------------------------------" 
}

function corpo_email { 
	echo "Subject: Lista de usuarios com cota acima de $limiteAlerta% " > $listaUsers
	echo "From: $email " >> $listaUsers 
	echo "To: $email " >> $listaUsers
	echo "" >> $listaUsers
	echo "" >> $listaUsers
	echo "Ola, usuarios abaixo estao com cota acima dos $limiteAlerta%, favor verificar. Obrigado" >> $listaUsers
	echo "" >> $listaUsers
	echo "conta de email;display name;percentual de cota" >>  $listaUsers
}




#INICIO -----------------------------------------------------------------------------------------


dt=`date +%Y%m%d"_"%H%M%S`
echo "--------- Iniciando as $dt "
echo ""

if [ -f "$crtl" ]
then 
    echo "Ja em execucao, abortando execucao"
else 
    echo $dt > $crtl
    corpo_email
	gera_lista
	estat 
	estat >>  $listaUsers
	avisar
	rm $crtl
fi

echo "--------- Finalizado as `date +%Y%m%d"_"%H%M%S`  "
echo ""
