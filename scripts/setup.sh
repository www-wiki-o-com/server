#!/bin/bash
#      __      __    __               ___
#     /  \    /  \__|  | _ __        /   \
#     \   \/\/   /  |  |/ /  |  __  |  |  |
#      \        /|  |    <|  | |__| |  |  |
#       \__/\__/ |__|__|__\__|       \___/
#
# A web service for sharing opinions and avoiding arguments
#
# file        scripts/setup.sh
# copyright   GNU Public License, 2018
# authors     Frank Imeson
# brief       A managment script for setting up the server environment

# Environment variables
DOMAINNAME=$(hostname -d)
PROJECT_DIR="/home/django"
CONFIG_DIR="$PROJECT_DIR/config"
VENV_DIR="$PROJECT_DIR/venv"
/home/django/config/local.env_vars.py

# Parse arguments
APACHE=false
BASH_RC=false
CRONTAB=true
EMAIL=false
POSTGRES=false
REPOS=fals
UBUNTU=false
VENV=false
while getopts "abcepruv" flag; do
  case $flag in
    a)
      APACHE=true
      ;;
    b)
      BASH_RC=true
      ;;
    c)
      CRONTAB=true
      ;;
    e)
      EMAIL=true
      ;;
    p)
      POSTGRES=true
      ;;
    r)
      REPOS=true
      ;;
    u)
      UBUNTU=true
      ;;
    v)
      VENV=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

# Setup Apache
if [ $APACHE == true ]; then
  if [ "$EUID" -eq 0 ]; then
    echo "Configuring Apache..."
  else
    echo "Please run as root to configure Apache."
    exit
  fi
  
  cmd="rm -f /etc/apache2/sites-available/wiki-o.conf"; 
  echo $cmd
  $cmd
  if [ "$DOMAINNAME" == "wiki-o.com" ]; then
    cmd="ln -s $CONFIG_DIR/a2host.apache.conf /etc/apache2/sites-available/wiki-o.conf"
    echo $cmd
    $cmd
  else
    cmd="ln -s $CONFIG_DIR/a2mirror.apache.conf /etc/apache2/sites-available/wiki-o.conf"
    echo $cmd
    $cmd
  fi
  cmd="rm /etc/apache2/sites-enabled/*"
  echo $cmd
  $cmd
  cmd="ln -s /etc/apache2/sites-available/wiki-o.conf /etc/apache2/sites-enabled/wiki-o.conf"
  echo $cmd
  $cmd
  grep -q "WSGIPythonHome $VENV_DIR" /etc/apache2/mods-enabled/wsgi.conf
  if [ $? -eq 1 ]; then
    echo "You must manually add: WSGIPythonHome $VENV_DIR to /etc/apache2/mods-enabled/wsgi.conf (just before </IfModule>)"
  fi
  cmd="apache2ctl configtest"
  echo $cmd
  $cmd
  cmd=systemctl restart apache2
  echo $cmd
  $cmd
  echo "Done."
fi

# Setup .bashrc
if [ $BASH_RC == true ]; then
  echo "Updating .bashrc"
  source=""
  if [ "$DOMAINNAME" == "wiki-o.com" ]; then
    source="source $CONFIG_DIR/a2host.bashrc"
  elif [ "$DOMAINNAME" == "wiki-x.com" ]; then
    source="source $CONFIG_DIR/a2mirror.bashrc"
  fi
  grep -q "$source" $HOME/.bashrc
  if [ $? -eq 1 ]; then
    cmd="cp $HOME/.bashrc $HOME/.bashrc_old"
    echo $cmd
    $cmd
    sed -i 's|\\w|\\W|g' $HOME/.bashrc
    echo $cmd
    $cmd
    echo "echo $source >> $HOME/.bashrc"
    echo $source >> $HOME/.bashrc
    diff $HOME/.bashrc $HOME/.bashrc_old
  else
    echo ".bashrc already contains $source"
    echo "$DOMAINNAME"
  fi
  echo "Done."
fi

# Setup crontab
if [ $CRONTAB == true ]; then
  echo "Updating crontab"
  source=""
  if [ "$DOMAINNAME" == "wiki-o.com" ]; then
    source="$CONFIG_DIR/a2host.crontab"
  elif [ "$DOMAINNAME" == "wiki-x.com" ]; then
    source="$CONFIG_DIR/a2mirror.crontab"
  fi
  cat $source|crontab -
  echo "Done."
fi

# Setup the email server
if [ $EMAIL == true ]; then
  if [ "$EUID" -eq 0 ]; then
    echo "Setting up the email server..."
  else
    echo "Please run as root to setup the email server."
    exit
  fi

  if [ "$DOMAINNAME" == "wiki-o.com" ]; then
    echo "wiki-o.com" > /etc/mailname
    echo "postmaster:           $USER@wiki-o.com" >> /etc/aliases
    echo "root:                 $USER@wiki-o.com" >> /etc/aliases

    POSTFIX_DIR=/etc/postfix
    mv $POSTFIX_DIR/main.cf $POSTFIX_DIR/main.cf_old
    ln -s $CONFIG_DIR/a2host.postfix.main.cf $POSTFIX_DIR/main.cf

    echo "accounts@wiki-o.com   $USER@wiki-o.com" >> $POSTFIX_DIR/virtual
    echo "contact@wiki-o.com    $USER@wiki-o.com" >> $POSTFIX_DIR/virtual
    echo "admin@wiki-o.com      $USER@wiki-o.com" >> $POSTFIX_DIR/virtual
  elif [ "$DOMAINNAME" == "wiki-x.com" ]; then
    echo "wiki-x.com" > /etc/mailname
    echo "postmaster:           $USER@wiki-x.com" >> /etc/aliases
    echo "root:                 $USER@wiki-x.com" >> /etc/aliases

    POSTFIX_DIR=/etc/postfix
    mv $POSTFIX_DIR/main.cf $POSTFIX_DIR/main.cf_old
    ln -s $CONFIG_DIR/a2host.postfix.main.cf $POSTFIX_DIR/main.cf

    echo "accounts@wiki-x.com   $USER@wiki-x.com" >> $POSTFIX_DIR/virtual
    echo "contact@wiki-x.com    $USER@wiki-x.com" >> $POSTFIX_DIR/virtual
    echo "admin@wiki-x.com      $USER@wiki-x.com" >> $POSTFIX_DIR/virtual    
  fi    
  
  postmap $POSTFIX_DIR/virtual
  service postfix reload
  echo "Done."

  echo "Review the following files for proper construction:"
  echo ""
  
  echo "/etc/mailname"
  cat /etc/mailname
  echo ""
  
  echo "/etc/aliases"
  cat /etc/aliases
  echo ""

  echo $POSTFIX_DIR/virtual
  cat $POSTFIX_DIR/virtual
  echo ""

  echo "Run the following if there were any manual changes:"
  echo "sudo postmap $POSTFIX_DIR/virtual"
  echo "sudo service postfix reload"
fi

# Setup repositories
if [ $REPOS == true ]; then
  echo "Setting up repositories..."

  WIKI_O_DIR=$PROJECT_DIR/www.wiki-o.com
  if [[ ! -d $WIKI_O_DIR ]]; then
    git clone https://github.com/www-wiki-o-com/www-wiki-o-com.git $WIKI_O_DIR
    python3 $WIKI_O_DIR/manage.py collectstatic
  fi
  
  ENV_VARS_FILE=$WIKI_O_DIR/wiki_o/env_vars.py
  if [[ ! -f $ENV_VARS_FILE ]]; then
    if [ "$DOMAINNAME" == "wiki-o.com" ]; then
      ln -s $CONFIG_DIR/a2host.env_vars.py $ENV_VARS_FILE
    elif [ "$DOMAINNAME" == "wiki-x.com" ]; then
      ln -s $CONFIG_DIR/a2mirror.env_vars.py $ENV_VARS_FILE
    else
      ln -s $CONFIG_DIR/local.env_vars.py $ENV_VARS_FILE
    fi    
  fi

  FEEDBACK_WIKI_O_DIR=$PROJECT_DIR/feedback.wiki-o.com
  if [[ ! -d $FEEDBACK_WIKI_O_DIR ]]; then
    git clone https://github.com/www-wiki-o-com/feedback-wiki-o-com.git $FEEDBACK_WIKI_O_DIR
    python3 $FEEDBACK_WIKI_O_DIR/manage.py collectstatic
  fi

  ENV_VARS_FILE=$FEEDBACK_WIKI_O_DIR/feedback_wiki_o/env_vars.py
  if [[ ! -f $ENV_VARS_FILE ]]; then
    if [ "$DOMAINNAME" == "wiki-o.com" ]; then
      ln -s $CONFIG_DIR/a2host.env_vars.py $ENV_VARS_FILE
    elif [ "$DOMAINNAME" == "wiki-x.com" ]; then
      ln -s $CONFIG_DIR/a2mirror.env_vars.py $ENV_VARS_FILE
    else
      ln -s $CONFIG_DIR/local.env_vars.py $ENV_VARS_FILE
    fi    
  fi

  echo "Done"
fi

# Setup postgres
if [ $POSTGRES == true ]; then
  if [ "$EUID" -eq 0 ]; then
    echo "Setting up postgres..."
  else
    echo "Please run as root to setup postgres."
    exit
  fi

  # create default account
  sudo -u postgres psql -c "create user $PGUSER with encrypted password '$PGPASSWORD';"
  sudo -u postgres psql -c "alter user $PGUSER CREATEDB;"
 
  # create the main database
  sudo -u postgres psql -c "create database wiki_o;"
  sudo -u postgres psql -c "grant all privileges on database wiki_o to $PGUSER;"

  # create the feedback database (the forum)
  sudo -u postgres psql -c "create database feedback_wiki_o;"
  sudo -u postgres psql -c "grant all privileges on database feedback_wiki_o to $PGUSER;"

  echo "Done"
fi

# Setup Ubuntu
if [ $UBUNTU == true ]; then
  if [ "$EUID" -eq 0 ]; then
    echo "Setting up ubuntu packages..."
  else
    echo "Please run as root."
    exit
  fi
  apt update
  apt install git
  apt install postgresql
  apt install alpine
  apt install python3
  apt install python3-pip
  apt install apache2 
  apt install libapache2-mod-wsgi-py3
  apt install dnsutils
  apt install vim
  localedef -i en_US -f UTF-8 en_US.UTF-8
fi

# Setup the virtual environment
if [ $VENV == true ]; then
  echo "Creating the virtual environment..."
  pip3 install --upgrade pip
  pip3 install virtualenv
  rm $PROJECT_DIR/venv -rf
  virtualenv $PROJECT_DIR/venv
  source $PROJECT_DIR/venv/bin/activate
  pip install -r $PROJECT_DIR/www.wiki-o.com/requirements.freeze
  pip install -r $PROJECT_DIR/feedback.wiki-o.com/requirements.freeze
  echo "Done."
fi

