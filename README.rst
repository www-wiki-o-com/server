Wiki-O Documentation
=======================================



How to Use This Document
=======================================

::

    $ pip install restview
    $ restview README.rst



A2 Hosting
============

::

    Server Name: server.wiki-o.com
    OS: Ubuntu 16



Requirements
============

- Ubuntu 16 (VPS)
- Python 3.5, 3.6
- Django 2.1, 2.2
- Bootstrap 4.1

Ubuntu Packages
::

    $ sudo apt update
    $ sudo apt install git
    $ sudo apt install postgresql
    $ sudo apt install alpine
    $ sudo apt install python3
    $ sudo apt install python3-pip
    $ sudo apt install apache2 
    $ sudo apt install libapache2-mod-wsgi-py3
    $ sudo apt install dnsutils
    $ sudo apt install vim
    $ export LC_ALL=C
    $ pip3 install --upgrade pip
    $ pip3 install virtualenv


SSH
============

Step 1: Setup new user
::

    $ ssh -p 7822 root@75.98.169.10
    $ adduser username
    $ su username
    $ cd
    $ mkdir .ssh
    $ touch .ssh/authorized_keys
    $ chmod 700 .ssh
    $ chmod 600 .ssh/authorized_keys
    $ vi .ssh/authorized_keys
        Add: public key (cut and paste)

Step 2: Setup sudo
::

    $ vi /etc/group
    sudo: username

Step 3: Disable SSH root access
::

    $ vi /etc/ssh/sshd_config
      PermitRootLogin no
      AllowUsers user1 user2 user3 ...

Step 4: Disable password login except for bob
::

    PasswordAuthentication no
    Match User bob
      PasswordAuthentication yes
    Match all
    
Step 5: Make sure to test before logging out
::

    $ sudo service ssh restart
    $ ssh -p 7822 username@75.98.169.10

Step 6: Setup gnome terminal
::

    create new profile named a2hosting
    set custom command to: ssh -p 7822 username@75.98.169.10
 
Step 7: Setup bashrc (optionaly use bashrc /home/django/config/bashrc.a2hosting)
::

     # Aliases
     alias cls='printf "\033c"'
     alias python='python3'
     alias pip='pip3'
     alias mail=alpine
     alias pine=mail
     
     # Paths
     export PYTHONPATH=/usr/local/lib/python3.5/:~/lib/python/:$PYTHONPATH
     PATH=~/bin:/home/django/scripts:$PATH
     
     # Django
     export DJANGO_SETTINGS_MODULE=wiki_o.settings
     source /home/django/venv/bin/activate
     cd /home/django/www.wiki-o.com


GIT
============

Step 1: Create and Upload
::

    $ git clone --bare /path/to/repo wiki-o.git
    $ tar -czf repo.tgz wiki-o.git
    $ pscp -P 7822 wiki-o.tgz username@75.98.169.10:~

Step 2: Decompress and Clone
::

    $ ssh -p 7822 username@75.98.169.10
    $ tar -xzf wiki-o.tgz
    $ sudo mv wiki-0.git /home
    $ rm wiki-o.tgz

    $ git clone wiki-o.git
    $ sudo mv wiki-o /home

    $ cd .git
    $ rm config
    $ ln -s ../config/local.git_config config

    

Step 3: Organize Directories
::

    working dir: /home/django
    git repo:    /home/django.git

Step 4: User Config
::

    $ git config --global user.email  "user@email.com"
    $ git config --global user.name   "Your Name"



Virtual Envionment
==================

Step 1: Setup Environment (add config to bashrc)
::

    $ cd /home/django
    $ virtualenv venv
    $ source venv/bin/activate

Step 2: Install Packages
::

  To install requirments:

    $ pip3 install -r /home/django/config/pip.requirements

  To show the requirments:

    $ pip3 freeze


Postgrsql
============

Step 1: Setup Database
::

    $ cd ~
    $ sudo -u postgres psql -c "create database wiki_o;"
    $ sudo -u postgres psql -c "create user django with encrypted password 'mypass';"
    $ sudo -u postgres psql -c "grant all privileges on database wiki_o to django;"
    $ sudo -u postgres psql -c "alter user django CREATEDB;"



Django
============

Step 1: Migrate
::

    $ cd /home/django/www.wiki-o.com
    $ ln -s /home/django/config/a2host.envionment.py settings.py
    $ cd ..
    $ python3 manage.py migrate
    $ python3 manage.py collectstatic

Step 2: Restore Database
::

    $ python3 manage.py loaddata /home/django/backup.json

Step 3: Envionment Variables
::
    
    $ ln -s /home/django/config/local.env_vars.py www.wiki-o.com/wiki_o/env_vars.py
    $ ln -s /home/django/config/local.env_vars.py feedback.wiki-o.com/wiki_o/env_vars.py

Step 4: Test
::

    $ python3 manage.py runserver 75.98.169.10:8000



Server
============

Config:
::

    /etc/hostname:
      server

    /etc/resolve.conf
      domain      wiki-o.com
      nameserver  75.98.161.224
      nameserver  69.39.86.5

    DOMAIN POINTER
      Pointer Type  URL Standard
      Directory     75.98.169.10

    DNS RECORDS
    A     @         75.98.169.10
    A     *         75.98.169.10
    A     mx        75.98.169.10
    A     ftp       75.98.169.10
    A     pop       75.98.169.10
    A     imap      75.98.169.10
    A     smtp      75.98.169.10
    A     webmail   75.98.169.10
    A     email     75.98.169.10
    A     mail      75.98.169.10
    MX    @         mail.wiki-o.com  Priority: 30
    MX    *         mail.wiki-o.com  Priority: 30
    NS    @         ns1.domain.com
    NS    @         ns2.domain.com
    SOA   @         ns1.domain.com. dnsadmin.domain.com. 2018111907 10800 3600 604800 3600
    TXT   @         v=spf1 ip4:75.98.169.10/18 ?all



Apache
============

Step 1: Configure
::

    $ cd /etc/apache2/sites-available
    $ sudo ln -s /home/django/config/a2host.apache2.conf wiki-o.conf
    $ cd /etc/apache2/sites-enabled
    $ sudo rm *
    $ sudo ln -s ../sites-available/wiki-o.conf .
    $ cd /etc/apache2/mods-enabled
    $ vi wsgi.conf
        Add the following to the end of the file but before </IfModule>: 
        WSGIPythonHome /home/django/venv

Step 2: Test
::

    $ sudo apache2ctl configtest

Step 3: Launch
::

    $ sudo systemctl restart apache2


Postfix
============

Step 1: Network
::

    /etc/mailname
      wiki-o.com
       
    /etc/aliases
      postmaster:           username@wiki-o.com
      root:                 username@wiki-o.com  
    $ sudo newaliases

Step 2: Mail Serversudo systemctl restart apache2
::

    $ cd /etc/postfix
    $ sudo mv main.cf main.cf_old
    $ sudo ln -s /home/django/config/a2host.postfix.main.cf main.cf
    
    /etc/postfix/virtual
      accounts@wiki-o.com   username@wiki-o.com
      contact@wiki-o.com    username@wiki-o.com
      admin@wiki-o.com      username@wiki-o.com   
    $ sudo postmap virtual

Step 3: SSL (https://e-rave.nl/create-a-self-signed-ssl-key-for-postfix)
::  

    $ sudo tar --same-owner -xpzf certificates.tgz
    $ sudo cp -a certificates/private/* /etc/ssl/private
    $ sudo cp -a certificates/ssl/certs/* /etc/ssl/certs
    $ sudo rm certificates -rf
    $ sudo rm certificates.tgz

Step 4: Test
::

    $ sudo service postfix reload
    $ alpine



Crontab
============

::

    0 0 * * * /home/django/scripts/daily_maintence.sh

    
