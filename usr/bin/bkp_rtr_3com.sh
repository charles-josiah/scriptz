#!/usr/bin/expect -f

set hostname [lindex $argv 0]
set usuario "XXXXX"
set senha "XXXXXXX" 
set getDia [clock seconds]
set dia [clock format $getDia -format  "%Y%m%d"] 
set TFTPSERVER <IP/HOSTNAME>


spawn telnet $hostname 
expect -exact "Username:"
send -- "$usuario\r"
expect -exact "Password:"
send -- "$senha\r"
sleep 2
send -- "backup startup-configuration to $TFTPSERVER RTR-$dia-$hostname-startup.cfg\r"
send -- "quit\r"
expect eof
