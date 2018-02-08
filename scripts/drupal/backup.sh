#!/bin/sh
##
# Pre deployment db backup.
#

mkdir -p /app/docroot/sites/default/files/private
drush sql-dump --gzip --result-file=/app/docroot/sites/default/files/private/pre_deploy_backup.sql
