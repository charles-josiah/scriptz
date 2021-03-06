#!/bin/bash
# Script simples de integração do MTMON (http://mtmon.multitask.com.br) com Zabbix. 
# Deve ser adicionado no diretorio: /usr/lib/zabbix/alertscripts/
# Lembrado que é necessário configurar todo a parte de triggers, actions, comandos, media types, etc...  
# Desenvolvido por: Charles Josiah (charles.alandt at gmail.com) 
# Atualizado: 15/06/2020 - Novas opções :D 
#             22/06/2020 - add campo origem. 

# no subject define os 3 niveis de alerta: 0 1  2
# na mensagem default, temos os serguintes itens a serem analisados.
#  Problem started at {EVENT.TIME} on {EVENT.DATE}
#  Problema: {EVENT.NAME}
#  Host: {HOST.NAME}
#  Severity: {EVENT.SEVERITY}
#  ID: {EVENT.ID}
#  objeto: conectividade
#  procedimento:  link

LOG=/var/log/zabbix/zabbix-mtmon.log                            #log da execução para eventual validação
mt_evento=/usr/local/Multitask/mtmon/bin/mtmon_evento.pl        #local do mtmon_evento para chamada do acionamento.
rand="`echo $RANDOM`"
zbx_Ticket="/tmp/zbx.ticket.$rand" 
d2u=dos2unix
C_iconv=iconv


echo "----------------------" > $zbx_Ticket
echo "$1" >> $zbx_Ticket
echo "$2" >> $zbx_Ticket
echo "$3" >> $zbx_Ticket
echo "----------------------" >> $zbx_Ticket

#OLDIFS=$IFS
#IFS=$'\n'
#echo "$3" >> $zbx_Ticket
#IFS=$OLDIFS

$d2u  $zbx_Ticket >> $LOG 

echo "--------------" >> $LOG
serv="`cat $zbx_Ticket  | grep -i host | sed 's/.*://'` " 2>> $LOG
problema="`cat $zbx_Ticket | grep -i 'Problema: ' | sed 's/Problema://' | $C_iconv -f utf8 -t ascii//TRANSLIT  `" 2>> $LOG
zbx_ID="`cat $zbx_Ticket | grep ID  | sed 's/.*://' `" 2>> $LOG
objeto="`cat $zbx_Ticket | grep objeto | sed 's/.*://' `" 2>> $LOG
procedimento="`cat $zbx_Ticket | grep procedimento |  sed 's/.*://' `" 2>> $LOG
origem="`cat $zbx_Ticket | grep origem | sed 's/.*://' `" 2>> $LOG
aplicacao="`cat $zbx_Ticket | grep -i 'aplicacao: ' | sed 's/aplicacao://' | $C_iconv -f utf8 -t ascii//TRANSLIT  `" 2>> $LOG

echo " ticket file: $zbx_Ticket" >> $LOG
echo " severidade: $2" >> $LOG
echo " hostname: $serv"  >> $LOG
echo " problema: $problema" >> $LOG
echo " zbx_ID: $zbx_ID" >> $LOG 
echo " objeto: $objeto" >> $LOG
echo " procedimento: $procedimento" >> $LOG

echo "--------------" >> $LOG


$mt_evento --origem $origem  --servidor $serv --aplicacao $aplicacao  --objeto $objeto  --eventual --severidade $2 --notifica $procedimento  --mensagem "$problema" --dump $zbx_Ticket 


echo "$mt_evento --origem $origem  --servidor $serv --aplicacao $aplicacao  --objeto $objeto  --eventual --severidade $2  --notifica $procedimento --mensagem $problema --dump $3 " >> $LOG

echo >> $LOG 
echo "-`date `--------------------------------" >> $LOG




