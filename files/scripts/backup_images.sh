#!/bin/sh
set -x
#### BEGIN CONFIGURATION ####

# set dates for backup rotation
NOWDATE=`date +%Y-%m-%d-%H`
DAY_OF_MONTH=`date +%d`


# set backup directory variables
SRCDIR='{{project_root}}-data/media_root/images/'
DESTDIR='{{project_name}}-images'
LONG_TERM_BUCKET='{{long_term_backup_bucket}}'

#### END CONFIGURATION ####

# upload backup to s3
/usr/bin/s3cmd sync --skip-existing $SRCDIR s3://$LONG_TERM_BUCKET/$DESTDIR/ --storage-class=STANDARD_IA
