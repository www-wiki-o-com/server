#      __      __    __               ___
#     /  \    /  \__|  | _ __        /   \
#     \   \/\/   /  |  |/ /  |  __  |  |  |
#      \        /|  |    <|  | |__| |  |  |
#       \__/\__/ |__|__|__\__|       \___/
#
# A web service for sharing opinions and avoiding arguments
#
# file        config/a2host.bashrc
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
    python3 /home/django/feedback.wiki-o.com/manage.py runserver 75.98.169.10:8000 "$@"
  else
    python3 /home/django/www.wiki-o.com/manage.py runserver 75.98.169.10:8000 "$@"
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
