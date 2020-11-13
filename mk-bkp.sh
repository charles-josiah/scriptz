##########################
# Script para backup de mikrotik remotos 
# Script não esta bonito, foi feito em 5 min para resolver um problema de backup
# Recomendado a troca de chaves para não solicitar mais senhas de acesso ao MK
# Para realizar a troca de chaves SSH, vide script mk_chaves.sh
# 
# by: Charles Josiah
# Email: charles.alandt(a)gmail.com
# Data: 13/11/2020 

porta="2222  -i ~/Acessos/Chave/id_chave_MT"          #PORTA DE CONEXÃO MK E CHAVE PRIVADA

for a in MK_IP_1 MK_IP_2 MK_IP_3 MK_IP_4
do 
  bkpfile="`date +%Y%m%d`-$a"
  echo "Backup: $a - arq: $bkpfile" 
  ssh admin@$a -p$porta export file=$bkpfile
  sftp -P $porta admin@$a:$bkpfile.rsc
done
