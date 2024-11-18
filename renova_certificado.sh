#!/bin/bash

# ADD CRON: 0 */12 * * * root /root/renova_certificado.sh 

# Path to the log file
LOG_FILE="/var/log/certbot_renewal.log"

# Check if certbot is installed
if ! command -v certbot >/dev/null 2>&1; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Certbot is not installed. Exiting." | tee -a "$LOG_FILE"
    exit 1
fi

# Start the certificate renewal process
echo "--------------------------  $(date '+%Y-%m-%d %H:%M:%S') - Starting certificate renewal..." | tee -a "$LOG_FILE"
OUTPUT=$(certbot renew 2>&1)
RENEWAL_STATUS=$?

# Log the certbot output
echo "$OUTPUT" | tee -a "$LOG_FILE"

# Check if any certificates were renewed
if echo "$OUTPUT" | grep -q "The following certificates were successfully renewed"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Certificates were renewed. Reloading the web server..." | tee -a "$LOG_FILE"
    systemctl reload apache2
    if [ $? -eq 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Web server reloaded successfully." | tee -a "$LOG_FILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to reload the web server." | tee -a "$LOG_FILE"
    fi
elif [ $RENEWAL_STATUS -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - No certificates needed renewal." | tee -a "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Certificate renewal failed." | tee -a "$LOG_FILE"
fi

