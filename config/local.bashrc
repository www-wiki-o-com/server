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
alias drop_db='sudo -u postgres psql -c "drop database wiki_o;"'

RSYNC_CMD="rsync --update --exclude=.git --exclude=*.backup --exclude=*.pyc -avz"

function a2host () {
  if [ $# -lt 2 ]; then
    echo "Usage: a2host <push or pull> <path>"
    return
  fi

  X=$(readlink -f $2)
  if [ -d $X ]; then X="$X/"; fi

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

  if [ $1 == "push" ]; then
    $RSYNC_CMD "$X" -e "ssh -p 7822" "$USER@162.249.2.136:$X"
  elif [ $1 == "pull" ]; then
    $RSYNC_CMD -e "ssh -p 7822" "$USER@162.249.2.136:$X" "$X"
  else
    echo "Error: The first argument must be push or pull."
    echo "Usage: a2host <push or pull> <path>"
    return
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
