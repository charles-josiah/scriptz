#!/bin/sh
#
# Script "marreta", quase um martelo de Thor, para criar usuarios no zimbra (esse é feio.... mas funciona :D). 
# Ultima alteração: 03/11/2015 :D
#
#
Catalogo=users.txt
UsersAtuais=usersatuais.txt
UsuarioNovo=$1

> $Catalogo
> $UsersAtuais

echo Coletando dados

#Get usuarios do LDAP/AD
get_usuario_email_ldap.pl | grep $UsuarioNovo > $Catalogo

$Get todos os usuarios do zimbra

zmaccts | grep "@" | awk '{print $1}' > $UsersAtuais

cat $Catalogo |
while read linha
do
  user=`echo $linha | awk '{print $1}'`
  nome=`echo $linha | awk '{print $2}'`
  sobrenome=`echo $linha | awk '{print $3,$4,$5,$6}'`
  sobrenome1=`echo $linha | awk '{print $3}'`
  sobrenome2=`echo $linha | awk '{print $4}'`
  sobrenome3=`echo $linha | awk '{print $5}'`
  sobrenome4=`echo $linha | awk '{print $6}'`

echo
echo Modificando a conta - $user

  grep $user $UsersAtuais > /dev/null 2>&1
  if [ $? != 0 ]
  then
      operacao="ca" #cria usuario
  else 
      operacao="ma" #modifica usuario
  fi

  if [ -s $sobrenome1 ] 
  then
    zmprov $operacao $user givenName $nome DisplayName "$nome"
  else if [ -s $sobrenome2 ] 
      then
          sobrenome=`echo $linha | awk '{print $3}'`
          zmprov $operacao $user givenName $nome sn $sobrenome DisplayName "$nome $sobrenome"
      else if [ -s $sobrenome3  ] 
	       then
             sobrenome=`echo $linha | awk '{print $3,$4}'`
             zmprov $operacao $user givenName $nome sn "$sobrenome" DisplayName "$nome $sobrenome"
           else if [ -s $sobrenome4  ] 
	     	     then
                 sobrenome=`echo $linha | awk '{print $3,$4,$5}'`
                 zmprov $operacao $user givenName $nome sn "$sobrenome" DisplayName "$nome $sobrenome"
                else
                 sobrenome=`echo $linha | awk '{print $3,$4,$5,$6}'`
                 zmprov $operacao $user givenName $nome sn "$sobrenome" DisplayName "$nome $sobrenome"
                fi
           fi
	  fi
   fi

done
