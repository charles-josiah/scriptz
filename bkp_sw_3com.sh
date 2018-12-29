#!/usr/bin/expect -f

set hostname [lindex $argv 0]
set password "manager" 
set getDia [clock seconds]
set dia [clock format $getDia -format  "%Y%m%d"] 

spawn telnet $hostname 
expect "Login:"
send -- "manager\r"
expect "Password:"
send -- "$password\r"
sleep 2
send -- "system\r"
send -- "backupConfig\r"
send -- "save\r"
send -- "<IP DO TFTP SERVER>\r"
send -- "SW-$dia-$hostname.cfg\r"
sleep 5
send -- "quit\r"
send -- "logout\r"
expect eof

