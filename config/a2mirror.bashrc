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

function a2host () {
  if [ $# -eq 0 ]; then
    ssh -p 7822 $USER@wiki-o
    return
  fi

  if [ $# -eq 1 ]; then
    X=$(pwd)
  else
    X=$(readlink -f $2)
  fi

  if [ $# -gt 2 ]; then
    echo "Usage: a2mirror <push or pull> <path>"
    return
  fi

  if [ -d $X ]; then X="$X/"; fi

  RSYNC_CMD="rsync --update --exclude=.git --exclude=*.backup --exclude=*.pyc -avz"
  if [ $1 == "push" ]; then
    $RSYNC_CMD "$X" -e "ssh -p 7822" "$USER@75.98.169.10:$X" "${@:3}"
  elif [ $1 == "pull" ]; then
    $RSYNC_CMD -e "ssh -p 7822" "$USER@75.98.169.10:$X" "$X" "${@:3}"
  else
    echo "Error: The first argument must be push or pull."
    echo "Usage: a2host <push or pull> <path>"
    return
  fi
}

function adduser-to-postgres {
  if [ $# -ne 2 ]; then
    echo "Usage: adduser_to_postgres <username> <password>"
    return
  fi
  sudo -u postgres psql -c "create user $1 with encrypted password '$2';"
  sudo -u postgres psql -c "grant all privileges on database wiki_o to $1;"
  sudo -u postgres psql -c "grant all privileges on database feedback_wiki_o to $1;"
  sudo -u postgres psql -c "alter user $1 with superuser;"
}

function drop-db {
  if pwd | grep -q "feedback.wiki-o.com"; then
    sudo -u postgres psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'feedback_wiki_o' AND pid <> pg_backend_pid();"
    sudo -u postgres psql -c "drop database feedback_wiki_o;"
  else
    sudo -u postgres psql -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'wiki_o' AND pid <> pg_backend_pid();"
    sudo -u postgres psql -c "drop database wiki_o;"
  fi
}

function create-db {
  if pwd | grep -q "feedback.wiki-o.com"; then
    sudo -u postgres psql -c "create database feedback_wiki_o;"
    sudo -u postgres psql -c "grant all privileges on database feedback_wiki_o to $PGUSER;"
  else
    sudo -u postgres psql -c "create database wiki_o;"
    sudo -u postgres psql -c "grant all privileges on database wiki_o to $PGUSER;"
  fi
}

function manage () {
  pushd .
  if pwd | grep -q "feedback.wiki-o.com"; then
    python3 /home/django/feedback.wiki-o.com/manage.py "$@"
  else
    python3 /home/django/www.wiki-o.com/manage.py "$@"
  fi
  popd
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
    ./manage.py test --verbosity=2 "$@"
  else
    cd /home/django/www.wiki-o.com/
    ./manage.py test --verbosity=2 "$@"
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

# Virutal Environment
source /home/django/venv/bin/activate
cd /home/django/www.wiki-o.com
export EDITOR=vim

# Private Environment Variables
source /home/django/config/local.env_vars.sh
