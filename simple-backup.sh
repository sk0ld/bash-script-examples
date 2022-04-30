#!/bin/bash


###    Script was tested with root, servers ssh keys exchange was done ####
###    Settings for cron  (crontab -e)   ####
###    m h  dom mon dow   command        ####
###    * */6 * * * /usr/local/sbin/simple-backup.sh      #####
###    For example script will execute each 6 hours

#Don't forget to make chmod +x
#chmod +x /usr/local/sbin/simple-backup.sh

#This is very simple backup script
BKPUSER=root

#backup server ip
BKPSRV="192.168.31.211"

#source directory
SRCDIR="/mnt/data/"

#backup directory (target)
BKPDIR="/mnt/bkpdata"

#rsync path
RSYNC="/usr/bin/rsync"

#date path and output
BKPSUBDIR=$BKPDIR/$(/usr/bin/date +%Y%m%d%H%M)

#check source directory
if ! [ -d $SRCDIR ]; then
mkdir $SRCDIR
fi


#Non-empty files creation
for i in {1..10};
do echo "It's a content of test file number $i" > $SRCDIR/test-file$i.txt ;
done


#Creation of external backup directory
ssh $BKPUSER@$BKPSRV "/usr/bin/mkdir -p  $BKPSUBDIR"


#Rsync actions
rm /var/log/rsyncd.log 2>&1 > /dev/null
$RSYNC -azqe ssh -Apgot --log-file='/var/log/rsyncd.log' $SRCDIR $BKPUSER@$BKPSRV:$BKPSUBDIR
cd /var/log/ && cp rsyncd.log rsyncd.log.old

#Check & delete outdated backups (created 7 days ago)
ssh $BKPUSER@$BKPSRV "/usr/bin/find $BKPDIR/ -mtime +7 -delete"

#Test check & delete of outdated backups (created 3 minutes ago)
#ssh $BKPUSER@$BKPSRV "/usr/bin/find $BKPDIR/ -amin +3 -delete"