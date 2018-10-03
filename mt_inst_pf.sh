#Script instalacao basica do Software de Monitoramento da Multitask - MTMON no pfsense
#Versao 1.0 alfa do beta
#Autor: Charles Alandt - charles.alandt@gmail.com


ABI="`/usr/sbin/pkg config abi`"
FREEBSD_PACKAGE_URL="https://pkg.freebsd.org/${ABI}/latest/All/"
FREEBSD_PACKAGE_LIST_URL="https://pkg.freebsd.org/${ABI}/latest/packagesite.txz"

fetch ${FREEBSD_PACKAGE_LIST_URL}
tar vfx packagesite.txz

AddPkg () {
        pkgname=$1
        pkginfo=`grep "\"name\":\"$pkgname\"" packagesite.yaml`
        pkgvers=`echo $pkginfo | pcregrep -o1 '"version":"(.*?)"' | head -1`
        env ASSUME_ALWAYS_YES=YES /usr/sbin/pkg add  ${FREEBSD_PACKAGE_URL}${pkgname}-${pkgvers}.txz
}


AddPkg perl5.28
AddPkg figlet
AddPkg sysinfo
AddPkg wget 
AddPkg yydecode
AddPkg p5-Socket6
AddPkg p5-Mozilla-CA
AddPkg p5-Net-SSLeay
AddPkg p5-IO-Socket-INET6
AddPkg p5-IO-Socket-SSL
AddPkg p5-IO-HTML
AddPkg p5-HTTP-Date
AddPkg p5-Encode-Locale
AddPkg p5-Digest-HMAC
AddPkg p5-Authen-NTLM
AddPkg p5-Try-Tiny
AddPkg p5-Net-HTTP
AddPkg p5-HTTP-Negotiate
AddPkg p5-HTTP-Daemon
AddPkg p5-HTTP-Cookies
AddPkg p5-HTML-Tagset
AddPkg p5-HTML-Parser
AddPkg p5-File-Listing
AddPkg p5-libwww
AddPkg p5-LWP-MediaTypes
AddPkg p5-WWW-RobotRules
AddPkg p5-URI
AddPkg p5-HTTP-Message 
AddPkg p5-LWP-Protocol-http10
AddPkg p5-Mail-Sender
AddPkg p5-Rcs
AddPkg p5-Text-ParseWords
AddPkg p5-CGI
AddPkg p5-Net-Telnet
AddPkg p5-Term-ReadKey
AddPkg p5-Net-Telnet-Cisco
AddPkg p5-Net-Telnet-Cisco-IOS
AddPkg p5-JSON
AddPkg p5-XML-Parser
AddPkg p5-AppConfig
AddPkg p5-Template-Toolkit
AddPkg p5-Template-Toolkit-Simple
AddPkg p5-ParseTemplate
AddPkg p5-Template-Simple
echo
echo
echo "Testando se foi tudo instalado...."
for modulo in  JSON CGI LWP Net::Ping Rcs Mail::Sender MIME::Base64 Net::Telnet Net::Telnet::Cisco Text::ParseWords  

do
  perl -M$modulo -e "print qq(\$$modulo::VERSION\t$modulo\n);"
done
echo
echo "Se tiver faltando modulo pare o processo de instalacao <crtl+c>"
read
echo
echo "Instalando o MTMON"
rm inst_* 
wget http://200.175.53.1/install/inst_mtadm.new
wget http://200.175.53.1/install/inst_mtmon_client.new
mv inst_mtadm.new inst_mtadm
mv inst_mtmon_client.new inst_mtmon_client
sh inst_mtadm
sh inst_mtmon_client
rm inst_*
/usr/local/Multitask/mtmon/bin/mtmon_evento.pl --aplicacao=teste --mensagem="Teste de conexao $(hostname)" --debug --eventual --severidade=0

echo "Configurando a Cron do MTMON"
echo " 59 * * * * root /usr/local/Multitask/mtadm/bin/MonitoraAmbiente.sh " > /etc/cron.d/MTMON
echo " 30 6,12,18 * * * root /usr/local/Multitask/mtadm/bin/mtwdog_files.pl --sincronizar " >> /etc/cron.d/MTMON
echo " 0,15,30,45 * * * * root /usr/local/Multitask/mtmon/bin/mtmon_cron.pl " >> /etc/cron.d/MTMON
echo " 0,15,30,45 * * * * root /usr/local/Multitask/mtadm/bin/ColetaMemoriaReal.sh " >> /etc/cron.d/MTMON
echo " @reboot root /usr/local/Multitask/mtmon/bin/mtmon_cron.pl " >> /etc/cron.d/MTMON
service cron restart
