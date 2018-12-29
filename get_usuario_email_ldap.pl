#!/usr/bin/perl
#
use Net::LDAP;

$ENV{'PATH'}.=":/usr/local/bin";
$ServidorLDAP='<IP DO SERVIDOR LDAP>'; #Ajustar o IP do servdior LDAP/AD
$UserBind='cn=root,o=<DOMINIO>,c=BR'; #Ajustar o DN do usuario de conexão  
$UserPwd='XXXX'; #Ajustar senha 

$ldap = Net::LDAP->new( $ServidorLDAP )
          or die "Unable to connect to $ServidorLDAP: $@\n";
$ldap->bind($UserBind, password => $UserPwd)
          or die "Unable to bind: $@\n";
$searchobj = $ldap->search(base => "o=<DOMINIO>,c=BR",  
                         filter => "(objectClass=mailUser)")
          or die "Unable to search to $ServidorLDAP: $@\n";

$searchobj->code && die $searchobj->error;
foreach $entry ($searchobj->entries) {
  $dn=$entry->dn;
  $usuario = $entry->get_value("uid");
  $email = $entry->get_value("mail");
  $nome = $entry->get_value("givenName");
  $sobrenome = $entry->get_value("sn");
  $display = $entry->get_value("displayname");
  print "$usuario\@DOMINIO.com.br $nome $sobrenome\n";
}

$ldap->unbind;

