#      __      __    __               ___
#     /  \    /  \__|  | _ __        /   \
#     \   \/\/   /  |  |/ /  |  __  |  |  |
#      \        /|  |    <|  | |__| |  |  |
#       \__/\__/ |__|__|__\__|       \___/
#
# A web service for sharing opinions and avoiding arguments
#
# file        config/local.bashrc
# copyright   GNU Public License, 2018
# authors     Frank Imeson
# brief       A collection of commands and environment variables

# some more ls aliases
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
  if [ $# -lt 2 ]; then
    echo "Usage: a2host <push or pull> <path>"
    return
  fi

  X=$(readlink -f $2)
  if [ -d $X ]; then X="$X/"; fi

  RSYNC_CMD="rsync --update --exclude=.git --exclude=*.backup --exclude=*.pyc -avz"
  if [ $1 == "push" ]; then
    $RSYNC_CMD "$X" -e "ssh -p 7822" "$USER@75.98.169.10:$X"
  elif [ $1 == "pull" ]; then
    $RSYNC_CMD -e "ssh -p 7822" "$USER@75.98.169.10:$X" "$X"
  else
    echo "Error: The first argument must be push or pull."
    echo "Usage: a2host <push or pull> <path>"
    return
  fi
}

function a2mirror () {
  if [ $# -lt 2 ]; then
    echo "Usage: a2host <push or pull> <path>"
    return
  fi

  X=$(readlink -f $2)
  if [ -d $X ]; then X="$X/"; fi

  RSYNC_CMD="rsync --update --exclude=.git --exclude=*.backup --exclude=*.pyc -avz"
  if [ $1 == "push" ]; then
    $RSYNC_CMD "$X" -e "ssh -p 7822" "$USER@162.249.2.136:$X" "${@:3}"
  elif [ $1 == "pull" ]; then
    $RSYNC_CMD -e "ssh -p 7822" "$USER@162.249.2.136:$X" "$X" "${@:3}"
  else
    echo "Error: The first argument must be push or pull."
    echo "Usage: a2host <push or pull> <path>"
    return
  fi
}

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
    ./manage.py test -v2 --failfast "$@"
  else
    cd /home/django/www.wiki-o.com/
    ./manage.py test -v2 --failfast "$@"
  fi
  popd
}

function run-server () {
  if pwd | grep -q "feedback.wiki-o.com"; then
    python3 /home/django/feedback.wiki-o.com/manage.py runserver "$@"
  else
    python3 /home/django/www.wiki-o.com/manage.py runserver "$@"
  fi
}

function restart-apache () {
  python3 /home/django/www.wiki-o.com/manage.py collectstatic
  python3 /home/django/feedback.wiki-o.com/manage.py collectstatic
  sudo systemctl restart apache2
}

# Paths
export PYTHONPATH=~/lib/python/:$PYTHONPATH
PATH=~/bin:/home/django/scripts:$PATH

# Virutal Env
source /home/django/venv/bin/activate
cd /home/django/www.wiki-o.com
export EDITOR=vim
