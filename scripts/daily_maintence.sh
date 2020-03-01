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

PROJECT_DIR="/home/django"
WWW_WIKI_O_DIR=$PROJECT_DIR/www.wiki-o.com
FEEDBACK_WIKI_O_DIR=$PROJECT_DIR/feedback.wiki-o.com

python3 $WWW_WIKI_O_DIR/manage.py backup
python3 $WWW_WIKI_O_DIR/manage.py clearsessions
python3 $WWW_WIKI_O_DIR/manage.py clean --categories

python3 $FEEDBACK_WIKI_O_DIR/manage.py backup
python3 $FEEDBACK_WIKI_O_DIR/manage.py clearsessions

$PROJECT_DIR/scripts/sync_user_data.sh