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

# Some more ls aliases
alias cls='printf "\033c"'
alias python='python3'
alias pip='pip3'
alias mail='alpine'
alias pine='mail'
alias gl='git log'
alias gs='git status'
alias gb='git branch'
alias postgres='sudo -u postgres psql postgres'

function adduser_to_postgres {
  if [ $# -ne 2 ]; then
    echo "Usage: adduser_to_postgres <username> <password>"
    return
  fi
  sudo -u postgres psql -c "create user $1 with encrypted password '$2';"
  sudo -u postgres psql -c "grant all privileges on database wiki_o to $1;"
  sudo -u postgres psql -c "grant all privileges on database feedback_wiki_o to $1;"
}

function drop_db {
  if pwd | grep -q "feedback.wiki-o.com"; then
    sudo -u postgres psql -c "drop database feedback_wiki_o;"
  else
    sudo -u postgres psql -c "drop database wiki_o;"
  fi
}

function restore () {
  if pwd | grep -q "feedback.wiki-o.com"; then
    python3 /home/django/feedback.wiki-o.com/manage.py restore "$@"
  else
    python3 /home/django/www.wiki-o.com/manage.py restore "$@"
  fi
}

function run-tests () {
  pushd .
  if pwd | grep -q "feedback.wiki-o.com"; then
    cd /home/django/feedback.wiki-o.com/
    ./manage.py test -v2 "$@"
  else
    cd /home/django/www.wiki-o.com/
    ./manage.py test -v2 "$@"
  fi
  popd
}

function run-server () {
  if pwd | grep -q "feedback.wiki-o.com"; then
    python3 /home/django/feedback.wiki-o.com/manage.py runserver 162.249.2.136:8000 "$@"
  else
    python3 /home/django/www.wiki-o.com/manage.py runserver 162.249.2.136:8000 "$@"
  fi
}

function restart-apache () {
  python3 /home/django/www.wiki-o.com/manage.py collectstatic
  python3 /home/django/feedback.wiki-o.com/manage.py collectstatic
  sudo systemctl restart apache2
}

# Paths
export PYTHONPATH=/usr/local/lib/python3.5/:~/lib/python/:$PYTHONPATH
PATH=~/bin:/home/django/scripts:$PATH

# Virutal Env
source /home/django/venv/bin/activate
cd /home/django/www.wiki-o.com
export EDITOR=vim
