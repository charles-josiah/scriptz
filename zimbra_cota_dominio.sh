#
# Script que gera o tamanho em GB num servidor Zimbra
# 
# 22/06/2016, by Charles Josiah, <charles.alandt at gmail.com>

servidor="NOME SERVIDOR ZIMBRA"

for dominio in ` zmprov gad `; do

	all_accounts=`zmprov gqu $servidor | grep $dominio | tr " " ";" `
	total=0
	for a in $all_accounts;do 
		e=`echo $a | awk -F";" '{print $3 }' ` 
		let total=$total+$e
	done 
	echo " Dominio: $dominio utilizado: `echo  ${total}/1024/1024/1024 | bc` Gb "
done
