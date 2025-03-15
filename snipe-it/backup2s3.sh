#!/bin/sh

LOGFILE="/var/log/snipeit-backup.log"


#---------3. Backup Asset Management ---------
usr/bin/php artisan snipeit:backup >> $LOGFILE

#---------4. Get the latest backup file from the directory ---------
cd /var/www/snipeit/storage/app/backups
Filename=$(ls -Art | tail -n 1)

#---------5. Upload the backup file to S3 bucket ---------
echo 'Backup uploading to S3 bucket'  >> $LOGFILE
/snap/bin/aws s3 cp $Filename s3://BUCKET_NAME/FOLDER_NAME/ >> $LOGFILE

#---------6. Remove all backups older than 3 days ---------
echo 'Deleting backup older than 3 days'  >> $LOGFILE
find /var/www/snipeit/storage/app/backups -type f -name '*.zip' -mtime +3 -exec rm {} \;

#---------7. Send email to me/group to inform the backup is complete ---------
SENDGRID_API_KEY="INSERT_YOUR_KEY_HERE"
BAK_DATETIME=`date +%F-%H:%M`
SUBJECT="Asset Mangement Backup was succcessful at: ${BAK_DATETIME}"
REQUEST_DATA='{"personalizations": [{ 
     "to": [{ "email": "foo@foo.com" }],
     "subject": "'"$SUBJECT"'"
  }],
  "from": {
      "email": "foo@foo.com",
      "name": "foo.com" 
  },
  "content": [{
      "type": "text/plain",
      "value": "This is an automated message to inform that Asset backup ('"$Filename"') completed successfully to S3 bucket."
  }]
}';

curl -X "POST" "https://api.sendgrid.com/v3/mail/send" \
 -H "Authorization: Bearer $SENDGRID_API_KEY" \
 -H "Content-Type: application/json" \
 -d "$REQUEST_DATA"

echo "Sent email notification via sendgrid" >> $LOGFILE
echo "***************END***************************" >> $LOGFILE