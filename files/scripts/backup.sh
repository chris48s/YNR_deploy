#!/bin/sh
set -x
#### BEGIN CONFIGURATION ####

# set dates for backup rotation
NOWDATE=`date +%Y-%m-%d-%H`
DAY_OF_MONTH=`date +%d`
EXPIRE=true
if  [ $DAY_OF_MONTH = 01 ] ;
then
    EXPIRE=false
fi



# set backup directory variables
SRCDIR='/tmp/s3backups_{{project_name}}'
DESTDIR='{{project_name}}'
SHORT_TERM_BUCKET='{{short_term_backup_bucket}}'
LONG_TERM_BUCKET='{{long_term_backup_bucket}}'

# database access details
HOST='127.0.0.1'
PORT='5432'
USER='{{project_name}}'
DB={{project_name}}

#### END CONFIGURATION ####

# make the temp directory if it doesn't exist
mkdir -p $SRCDIR

pg_dump  -Fc {{project_name}} -f $SRCDIR/$NOWDATE-backup.dump

# tar all the databases into $NOWDATE-backups.tar.gz
# cd $SRCDIR
# tar -czPf $NOWDATE-backup.tar.gz *.sql

# # upload backup to s3
/usr/bin/s3cmd put $SRCDIR/$NOWDATE-backup.dump s3://$SHORT_TERM_BUCKET/$DESTDIR/ --storage-class=STANDARD_IA

if [ !EXPIRE ]; then
    /usr/bin/s3cmd put $SRCDIR/$NOWDATE-backup.dump s3://$LONG_TERM_BUCKET/$DESTDIR/ --storage-class=STANDARD_IA
fi

/usr/bin/s3cmd expire s3://$SHORT_TERM_BUCKET --expiry-days=60


#remove all files in our source directory
cd
rm -f $SRCDIR/*
