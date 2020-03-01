#!/bin/bash
source /home/django/venv/bin/activate

#      __      __    __               ___
#     /  \    /  \__|  | _ __        /   \
#     \   \/\/   /  |  |/ /  |  __  |  |  |
#      \        /|  |    <|  | |__| |  |  |
#       \__/\__/ |__|__|__\__|       \___/
#
# Copyright (C) 2018 Wiki-O, Frank Imeson
#
# This source code is licensed under the GPL license found in the
# LICENSE.md file in the root directory of this source tree.

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