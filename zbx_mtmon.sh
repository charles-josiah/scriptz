# Script simples de integração do MTMON (http://mtmon.multitaks.com.br) com Zabbix. 
# Deve ser adicionado no diretorio: /usr/lib/zabbix/alertscripts/
# Lembrado que é necessário configurar todo a parte de triggers, actions, comandos, media types, etc...  
# Desenvolvido por: Charles Josiah (charles.alandt at gmail.com) 
#

LOG=/var/log/zabbix/zabbix-mtmon.log                            #log da execução para eventual validação
mt_evento=/usr/local/Multitask/mtmon/bin/mtmon_evento.pl        #local do mtmon_evento para chamada do acionamento.
serv=`echo "$2" | awk '/Host/ {print $2}' |sed 's/ //g'`        #Extrai o IP do servidor do campo {ALERT.MESSAGE}

$mt_evento  --servidor $serv --aplicacao zabbix --objeto link  --eventual --severidade 2  --notifica linux --mensagem "$1" --dump "$2" 

#Guarda um LOG da execução.
echo "-`date `--------------------------------" >> $LOG
echo "opcao1: $1 " >> $LOG
echo "opcao2: $2 " >> $LOG
echo "servidor: $serv " >> $LOG
