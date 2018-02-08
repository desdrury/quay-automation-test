#!/bin/sh
##
# Post comment with deployment URL to JIRA.
#

JIRA_URL=$1
USER=$2
PASSWORD=$3
BRANCH=$4
PREFIX=$5

extract_issue() {
  local branch=$1
  local prefix=$2
  echo $branch|sed -n "s/feature\/\($prefix-[0-9]\{1,\}\).*/\1/p"
}

branch_url() {
  local branch=$1
  branch="${branch// /-}"
  branch="${branch//_/-}"
  branch="${branch//\//-}"
  echo $branch | tr '[:upper:]' '[:lower:]'
}

generate_data() {
  cat <<EOF
  {
    "body": "$COMMENT"
  }
EOF
}

ISSUE=$(extract_issue "$BRANCH" $PREFIX)
[ "$ISSUE" == "" ] && echo "Branch does not contain issue number" && exit 0

BRANCH_URL=$(branch_url "$BRANCH")
COMMENT="Deployed to http://nginx-php-governors-$BRANCH_URL.lagoon.vicsdp.amazee.io"

echo "Posting comment \"$COMMENT\" for issue \"$ISSUE\""

DATA="{'body': $COMMENT}"
curl -s -u $USER:$PASSWORD -X POST --data "$(generate_data)" -H "Content-type: application/json" "$JIRA_URL/rest/api/2/issue/$ISSUE/comment"
