#!/bin/sh
##
# Download latest DB backup via drush.
#

LOCAL_PATH="/tmp/.data/"
DB_FILE_NAME="db.sql"
DUMP_PATH="/tmp/$DB_FILE_NAME"

fetch_db() {
  mkdir -p $LOCAL_PATH
  drush -y rsync @production:$DUMP_PATH $LOCAL_PATH
}

dump_db() {
  vendor/bin/drush @production sql-dump --skip-tables-key=common --result-file=$DUMP_PATH
}

# Attempt to fetch latest DB dump.
fetch_db

# Create new dump if failed.
if [ ! $? -eq 0 ]; then
 dump_db
 fetch_db
fi
