#  
# Script que limpa fila com dominios invalidos no postfix do zimbra.
# 
# 08/05/2018, by Charles Josiah, <charles.alandt at gmail.com>



dominio=("MAILER-DAEMON" "@MSM\.COM" "@YEMAIL\.COM" "@HOPTMAIL\.COM" "@HTMAIL\.COM" "@HOTMAIL\.CO" "@LIVE\.COM\.BR" "@OUTOOK\.COM"  "@GMAAIL\.COM" "@HOMAIL\.COM" "@HOOTMAIL\.COM" "@HORMAIL\.COM" "@HOTAMIL\.COM" "@HOTMAI\.COM" "@HOTMAIIL\.COM" "@HOTMAIOL\.COM" "@HOTMAL\.COM" "@IHOTMAIL\.COM"  "@HTOMAIL\.COM" "@GAMAIL\.COM" "@FACE\.COM" "@HOTMIA\.COM" "@HOMTAIL\.COM"  "@HOTMIAL\.COM" "@LIV\.COM" "@HOTM.\AIL\.COM" "@LAIVE\.COM" "@OUTLOCK\.COM" "@GEMAIL\.COM" "@OUTOLOOK\.COM" "@OUTOLOOCK\.COM" "@OUTLOOCK\.COM" "@HOYMAIL\.COM" "@HOMTIAL\.COM" "@GMAL\.COM"  "@HOTTMAIL\.COM" "@GMAILO\.COM" "@GMAIL\.CO" "@GMAIIL\.COM" "@HOTAMAIL\.COM" "@HOATMAIL\.COM" "@HOTAIL\.COM" "@OUTOLOK\.COM" "@OUTOLUK\.COM" "@OUTLUK\.COM" "@BOOL\.COM\.BR" "@2014.com"  "@OUTLOK\.COM" "@GTMAIL\.COM" "@HOTMIAIL\.COM" "@ALTLUCK\.COM" "@LIVI\.COM" "@ROOTMAIL\.COM" "@HOTRMIAL\.COM" "@FACEBOOK\.COM" "@HOTMNAIL\.COM" "@HIOTMAIL\.COM")


echo "Iniciando: `date`"
  for i in "${dominio[@]}"; do
  	echo $i
	        /opt/zimbra/common/sbin/postqueue -p | tail -n +2 | awk 'BEGIN { RS = "" } /'$i'/ { print $1 }' | tr -d '*!' | /opt/zimbra/common/sbin/postsuper -d -

	done
echo "Finalizado: `date`"
