#!/bin/bash
#      __      __    __               ___
#     /  \    /  \__|  | _ __        /   \
#     \   \/\/   /  |  |/ /  |  __  |  |  |
#      \        /|  |    <|  | |__| |  |  |
#       \__/\__/ |__|__|__\__|       \___/
#
# A web service for sharing opinions and avoiding arguments
#
# file        scripts/daily_maintence.sh
# copyright   GNU Public License, 2018
# authors     Frank Imeson
# brief       A managment script for daily maintence

PROJECT_DIR="/home/django"
WWW_WIKI_O_DIR=$PROJECT_DIR/www.wiki-o.com
FEEDBACK_WIKI_O_DIR=$PROJECT_DIR/feedback.wiki-o.com

python3 $WWW_WIKI_O_DIR/manage.py backup
python3 $WWW_WIKI_O_DIR/manage.py clearsessions

python3 $FEEDBACK_WIKI_O_DIR/manage.py backup
python3 $FEEDBACK_WIKI_O_DIR/manage.py clearsessions

$PROJECT_DIR/scripts/sync_user_data.sh