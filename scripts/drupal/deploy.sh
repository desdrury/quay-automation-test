#!/bin/sh
##
# Drupal deployment.
#

drush updb -y
drush cim -y
drush cr -y
