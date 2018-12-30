#!/bin/bash

###########
# Outro script de backup de dados, porem esse criptografa os arquivos.
# 
#


hostAtual=`hostname`

chave="XXXXXXXXXXX"  #chave de criptografia
cmdEncrypt="openssl aes-256-ecb -e -pass pass:$chave"
cmdDecrypt="openssl aes-256-ecb -d -pass pass:$chave"

cmdTar="tar jcvfP"
cmdPQP="rm -rf"

nomeArquivoBackup="backup.`date +%Y%m%d"_"%H%M%S`.tar.bz2"

arquivoBackup=("<dir para backup> <dir2 para backup>") 

#montar="mount"
#desMontar="umount"
#devicePenDrive="/dev/penDriveAGM"
#dirMontagem="/mnt"
#cmdCopia="cp"
#dirOrigem="./"

acerto=0
erro=0
codErro=0

#####################################################################################################################
tryCat()
   {

        if [ $? = 0 ];
                then
                        echo -n " [ OK ] " #>> $LOG
                        let acerto++
                else
                        echo -n " [ NOK ]" #>> $LOG
                        let erro++
        fi;
        let totalTestes++
        echo -n "[$dataInicialCmd][`date +%d/%m/%Y"-"%H:%M:%S`]" # >> $LOG
        tempoDecorridoCmd="$(expr $(date +%s) - $dataInicialCmdSegundos)"
        echo -n "[$(date -d "1970-01-01 $tempoDecorridoCmd sec" +%H":"%M":"%S)] " #>> $LOG
   }

preparaArquivos()
   {

         dataInicialCmd=`date +%d/%m/%Y"-"%H:%M:%S`
         dataInicialCmdSegundos="$(date +%s)"

         cmdCompactaArquivos=`$cmdTar $nomeArquivoBackup  ${arquivoBackup[@]} `
         tryCat
	 echo "Compactando diretorio:  ${arquivoBackup[@]}"
   }


encriptarArquivos()
   {
       dataInicialCmd=`date +%d/%m/%Y"-"%H:%M:%S`
       dataInicialCmdSegundos="$(date +%s)"
       cmdCryptografarArquivos=`$cmdEncrypt -in $nomeArquivoBackup -out $nomeArquivoBackup.enc`
       tryCat
       echo "Criptografando Arquivos"
   } 

removerTemporarios()
   {
       dataInicialCmd=`date +%d/%m/%Y"-"%H:%M:%S`
       dataInicialCmdSegundos="$(date +%s)"
       cmdRemoverTemporarios=`$cmdPQP $nomeArquivoBackup`
       tryCat
       echo "Removendo temporarios"
   }

echo "================================================================================"
echo "Script de backup iniciado: `date +%Y/%m/%d" "%H:%M:%S`"
preparaArquivos
encriptarArquivos
removerTemporarios
echo "Finalizado: `date +%Y/%m/%d" "%H:%M:%S`"
echo ""
echo "================================================================================"
