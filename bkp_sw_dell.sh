#!/usr/bin/expect -f

set hostname [lindex $argv 0]
set password "XXXXXXXX" #senha dos sw, recomendado criar um usuario com baixo level no switch. TFTP não é criptografado.
set getDia [clock seconds]
set dia [clock format $getDia -format  "%Y%m%d"] 
set tftpserver <IP_HOSTNAME_DO_SERVIDOR_TFTP> 

spawn telnet $hostname 
expect "User name:"
send -- "admin\r"
expect "Password:"
send -- "$password\r"
sleep 2
send -- "copy running-config tftp://$tftpserver/SW-$dia-$hostname.cfg\r"
send -- "quit\r"
send -- "exit\r"
expect eof
