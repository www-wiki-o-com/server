#!/bin/bash
#      __      __    __               ___
#     /  \    /  \__|  | _ __        /   \
#     \   \/\/   /  |  |/ /  |  __  |  |  |
#      \        /|  |    <|  | |__| |  |  |
#       \__/\__/ |__|__|__\__|       \___/
#
# A web service for sharing opinions and avoiding arguments
#
# file        scripts/sync_user_data.sh
# copyright   GNU Public License, 2018
# authors     Frank Imeson
# brief       A managment script for migrating/syncronozing user data from www.wiki-o.com
#             to feedback.wiki-o.com

# Setup
DOMAINNAME=$(hostname -d)
BACKUP_DIR="/home/django/backups/"
WWW_WIKI_O_DIR="/home/django/www.wiki-o.com/"
FEEDBACK_WIKI_O_DIR="/home/django/feedback.wiki-o.com/"
JSON_FILE="$BACKUP_DIR/tmp_user_data.json"

# Sync
python3 $WWW_WIKI_O_DIR/manage.py export_user_data $JSON_FILE --fields 'username' 'password'
sed -i 's/users.user/auth.user/g' $JSON_FILE
python3 $FEEDBACK_WIKI_O_DIR/manage.py loaddata $JSON_FILE
rm $JSON_FILE