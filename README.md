# Scriptz 
General, Brilliant, Generic Scripts and some technical adaptations  :D <br>

<ul> 
 <li> audit-local-users.ps1 - Automated local user discovery across Windows servers sourced from Active Directory or CSV, with intelligent RDP/SSH port validation. </li>
 <li> mt_inst_pf.sh - Initial script for installation of the Multitask Consultoria monitoring system - MTMON</li> 
 <li> bkp_rtr_3com.sh - “Heavy-duty” expect-based script for backup of 3COM routers</li>
 <li> bkp_sw_3com.sh - “Heavy-duty” expect-based script for backup of 3COM SuperStack series switches</li>
 <li> bkp_sw_dell.sh - “Heavy-duty” expect-based script for backup of DELL switches </li>
 <li> bkp_pfsense.sh - “Heavy-duty” bash script for pfSense backup</li>
 <li> bkp_pfsense_2.sh	- pfSense backup script, multi-host version, integrated with Telegram to send backup status notifications. </li>
 <li> bkp_servidores.sh - “Heavy-duty” shell script for backup of files and directories, firewall rules, routing, folder synchronizations, sends email, generates incremental/full backups, copies to Dell RDXXXX/external disks and sends email notifying completion with execution status. </li>
 <li> bkp_arquivos.sh - Another “heavy-duty” data backup script, but this one encrypts the data.</li>
 <li> get_usuario_email_ldap.pl - Retrieves user list from an LDAP server with the attribute objectClass=mailUser.
 <li> add_mod_usuarios_zimbra.sh - “Sledgehammer” script, almost Thor’s hammer, to create/modify users in Zimbra (this one is ugly.... but it works :D). Last update: 11/03/2015 :D
  <li> ldif2csv.pl - Perl script to convert LDIF file to CSV.
       this script is not mine, original link: http://painfullscratch.nl/code/ldif2csv.pl </li>
 <li> zbx_mtmon.sh - Integration script between Zabbix and MTMON </li>
 <li> zimbra_cota_user.sh	- Script generates domain user information in Zimbra, in the format: email;DisplayName;Quota;Quota Used;Status </li>
 <li> zimbra_cota_user_v2.sh - Script with improvements over zimbra_cota_user.sh. Quota limit alerts via email and monitoring.
 <li> zimbra_cota_dominio.sh - Script that provides information about the size of a domain in Zimbra </li>
 <li> zimbra_limpa_dom_invalidos.sh - Script that cleans queue with invalid domains in Zimbra Postfix.  </li>
 <li> zimbra_dataExpiraSenha.sh	- Script that generates report with password expiration date or if the password is expired in Zimbra.   </li>
 <li> zimbra_limpa_dom_invalidos.sh - Script that through a list of domains in an array, removes them from the queue. </li>
 <li> ConverteLogsFortigateSquidIP.pl - Converts Fortigate syslog format logs to Squid format. Possible to generate Fortigate browsing reports in the open-source tool SARG.
 <li> zimbra_sync_emails.sh - Script for synchronization of email accounts between 2 different Zimbra servers (or another that supports IMAP). 
 <li> zimbra_restore_agenda_tasks_contato.sh	- Script to restore Zimbra backup files created by zimbra_backup_agenda_tasks_contato.sh.
 <li> zimbra_backup_agenda_tasks_contato.sh	- Zimbra backup script for calendar, tasks and contacts
 <li> mk_backup.sh - Script for backup of remote MikroTiks, script is “that way” :D 
 <li> mk_chave.sh - SSH key copy script, activation for admin user; so there is no need to use username/password for admin login. Remember, script is “that way”, made in 5 minutes, too lazy to do everything manually :D :D :D  :D 
 <li> backup_dir_mysql.sh - Script for backup some files and dirs, mysqld and send status to the telegram. 
 <li> c_t_mysql.py - Easy script to test the connection with MySQL</li>
 <li> renova_certificado.sh - Another script to auto-renew certificate </li>
</ul>
Dir ./aws starting a collection (that way) of scripts for AWS.
 
<h6>
Note.: Most of these scripts were used to solve specific problems, some are very, very old, they do not have any "beauty" or organization.
All scripts are provided for reference purposes only. Adaptations, adjustments and proper testing are required before using them in production environments.
</h6>
