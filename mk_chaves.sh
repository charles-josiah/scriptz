##########################
# Script para copia e utilização de chaves SSH em mikrotik remotos 
# Script não esta bonito, foi feito em 5 min para resolver um problema de copia das chaves, sem a necessidade de conexão individual
# 
# by: Charles Josiah
# Email: charles.alandt(a)gmail.com
# Data: 13/11/2020 


porta=2222                                                #Porta de comunicacao
chave="/Users/charles.a/Acessos/Chave/id_chave_MT.pub"    #localizacao local da chave e nome
chavenome="id_chave_MT.pub"                               #nome da chave no mk

for a in MK_IP_1 MK_IP_2 MK_IP_3 
do 
  echo "Copiando chave para : $a"
  scp -P $porta $chave admin@$a:./ 
  ssh admin@$a -p $porta user ssh-keys import public-key-file=$chavenome user=admin 
done
