#
# Script que gera um CSV dos usuario e data de expiração da senha do usuario.
# Resultado: nome;tempo que falta para expirar;data de hoje;data expirada
# 
# 13/04/2017, by Charles Josiah, <charles.alandt at gmail.com>

 

listaUsuario=`zmprov -l gaa DOMINIO`

for a in $listaUsuario; 
	do

	    data=$(date +"%Y%m%d")
	    dthoje=$(date +"%d/%m/%Y")
		ultimaAlteracao=`zmprov ga $a  zimbraPasswordModifiedTime | grep zimbraPasswordModifiedTime: | cut -d " " -f 2 | cut -c 1-8 `
        dtultimaAlteracao=`date -d "$ultimaAlteracao"   +"%d/%m/%Y"`
#        echo "Ultima alteracao: $dtultimaAlteracao"
	    polExpira=`zmprov ga $a zimbraPasswordMaxAge | grep zimbraPasswordMaxAge |  cut -d " " -f 2  `
	    dtExpira=`date  '+%Y%m%d'  -d "$ultimaAlteracao  +$polExpira days" `
		#echo "dtExpira: $dtExpira"
		let expira=(`date +%s -d $dtExpira`-`date +%s -d $data`)/86400

        #echo "Falta: $expira dias  "

	echo "$a; $expira; $dtultimaAlteracao; $dthoje; `date -d "$dtExpira" +"%d/%m/%Y"`    "
		
	done

