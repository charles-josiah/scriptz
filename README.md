# Scriptz 
Scrips Gerais, Geniais, Genéricos e algumas adaptações técnicas  :D <br>

<ul> 
 <li> mt_inst_pf.sh - Script inicial para instalacao do sistema de monitoramento da Multitask Consultoria - MTMON</li> 
 <li> bkp_rtr_3com.sh - Script "baita" para backup via expect para backup de roteadores 3COM</li>
 <li> bkp_sw_3com.sh - Script "baita" para backup via expect para backup de switch 3COM das series SuperStack</li>
 <li> bkp_sw_dell.sh - Script "baita" para backup via expect para backup de switchs da DELL </li>
 <li> bkp_pfsense.sh - Script "baita" para backup do PFSENSE em bash</li>
 <li> bkp_pfsense_2.sh	- Script de backup do PFSENSE, porem multihost, com integração ao Telegram para envio do status do backup. </li>
 <li> bkp_servidores.sh - Script "baita" para backup em s hell script, de arquivos e diretorios, regras de firewall, roteamento, sincronismos de pastas, manda email, gera backup incremental/full, copia para disco Dell RDXXXX/Externos e manda email para avisar que acabou com status da execução. </li>
 <li> bkp_arquivos.sh - Mais um script "baita" para backup de dados, porem, esse criptografa os dados.</li>
 <li> get_usuario_email_ldap.pl - Busca lista de usuarios num servidor ldap  com o atributo objectClass=mailUser.
 <li> add_mod_usuarios_zimbra.sh - Script "marreta", quase um martelo de Thor, para criar/alterar usuarios no zimbra (esse é feio.... mas funciona :D). Ultima alteração: 03/11/2015 :D
  <li> ldif2csv.pl - Script perl para converter arquivo ldif para csv.
       esse script não é meu, segue link do original: http://painfullscratch.nl/code/ldif2csv.pl </li>
 <li> zbx_mtmon.sh - Add script de integração do Zabbix com  MTMON </li>
 <li> zimbra_cota_user.sh	- Script gera informações usuarios de dominio no zimbra, no formato: email;DisplayName;Cota;Cota Utilizada;Status </li>
 <li> zimbra_cota_user_v2.sh - Script com melhoramentos do script zimbra_cota_user.sh. Alerta de cotas acima do limite via email e monitoramento.
 <li> zimbra_cota_dominio.sh - Script de informações do tamanho de um dominio no zimbra </li>
 <li> zimbra_limpa_dom_invalidos.sh - Script que limpa fila com dominios invalidos no postfix do zimbra.  </li>
 <li> zimbra_dataExpiraSenha.sh	- Script que gera relatorio com a data de expiração ou se a senha expirada no zimbra.   </li>
 <li> zimbra_limpa_dom_invalidos.sh - Script que atravez de uma lista de dominios numa array, exclue os mesmos da fila. </li>
 <li> ConverteLogsFortigateSquidIP.pl - Converte log formato syslog do fortigate para formato squid. Possivel gerar relatorios de navegação do Fortigate na ferramenta opensource SARG.
 <li> zimbra_sync_emails.sh - Script para sincronização de contas de emails entre 2 servidores zimbra (ou outro que suporte imap) diferentes. 
 <li> zimbra_restore_agenda_tasks_contato.sh	- Script para restaurar arquivos de backup do zimbra pelo script zimbra_backup_agenda_tasks_contato.sh.
 <li> zimbra_backup_agenda_tasks_contato.sh	- Script de backup zimbra do agenda tasks e contatos
 <li> mk_backup.sh - Script para backup de mikrotiks remotos, script esta "daquele geito" :D 
 <li> mk_chave.sh - Script copia de chave ssh,  ativação no usuario admin; assim não precisa utilizar usuario/senha no login do admin. Lmebrando, script esta "daquele geito", feito em 5 min, preguiça de fazer tudo na mão :D :D :D  :D 
</ul>
Dir ./aws comecando uma coletania (daquele geito) de scripts para AWS.
 
<h6>
Obs.: Maioria destes scriptz foram utilizados para resolver problemas pontuais, a alguns são de muito, muito tempo atrás, não possuem nenhuma "boniteza" e organização nos mesmos.
</h6>
