#
# Script que gera um CSV dos usuario de um dominio no Zimbra, informações no formato: 
# email;DisplayName;Cota;Uso;Status
# No final mostra o tamanho total em Mb de todas as contas do dominio.
# 
# 13/01/2018, by Charles Josiah, <charles.alandt at gmail.com>

dominio="DOMINO_ZIMBRA"
servidor="`zmhostname`"
all_accounts=`zmprov gqu $servidor |  grep $dominio | tr " " ";" `
total=0
cmdZM=zmprov

for a in $all_accounts;do 
	e=`echo $a | awk -F";" '{print $3 }' ` #cota usada
	f=`echo $a | awk -F";" '{print $1 }' ` #nome da conta
  g=`echo $a | awk -F";" '{print $2 }' ` #cota total
  status=`$cmdZM ga $f  zimbraAccountStatus  | grep zimbraAccountStatus: | awk '{ print $2 }' ` 
  displayName=`$cmdZM ga $f displayName  | grep displayName: | awk '{ print $2 }' ` 

  echo -n "$f;$displayName"
  echo -n ";`echo "scale=2; ${g}/1024/1024" | bc`"   #divide para chegar em MB
  echo -n ";`echo "scale=2; ${e}/1024/1024" | bc`"   #divide para chegar em MB
  echo -n ";$status;"
  echo ""

  let total=$total+$e
done 
echo "Total usado: `echo  ${total}/1024/1024 | bc` Mb "
