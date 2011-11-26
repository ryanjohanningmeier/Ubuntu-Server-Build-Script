#!/bin/bash

read email;


# set time
dpkg-reconfigure tzdata;


# initial updates
apt-get update && apt-get -y dist-upgrade;


# must haves
apt-get -y install \
	build-essential \
	checkinstall \
	autogen \
	gcc \
	make \
	zlib1g-dev \
	libmysql++-dev;


# security and monitoring
apt-get -y install \
	munin-node \
	nagios-nrpe-server \
	ufw;


# apache2
apt-get -y install \
	apache2 \
	apache2-threaded-dev \
	apache2-mpm-prefork;

# configure
ulimit -s 256
a2enmod alias deflate status rewrite ssl;
a2dismod negotiation authn_file authz_default authz_groupfile;
chmod -R a+x,g+x /var/www/
chown -R www-data.www-data /var/www/


# php
apt-get -y install \
	libapache2-mod-php5 \
	php5 \
	php5-cgi \
	php5-suhosin \
	php5-cli \
	php5-dev \
	php5-curl \
	php5-gd \
	php5-gmp \
	php5-mcrypt \
	php5-memcache \
	php5-mysql \
	php5-imap \
	php5-sqlite \
	php5-tidy \
	php5-xmlrpc \
	php5-xsl \
	php-pear \
	php-apc;
a2enmod php5

# configure PHP
sed -i 's/"error_reporting = E_ALL & ~E_DEPRECATED"/"error_reporting = E_ALL & E_NOTICE"/' /etc/php5/cgi/php.ini
sed -i 's/"magic_quotes_gpc = On"/"magic_quotes_gpc = Off"/' /etc/php5/cgi/php.ini
sed -i 's/"short_open_tag = Off"/"short_open_tag = On"/' /etc/php5/cgi/php.ini
sed -i 's/"enable_call_time_pass_reference = Off"/"enable_call_time_pass_reference = On"/' /etc/php5/cgi/php.ini
sed -i 's/"cgi.fix_pathinfo = 0"/"cgi.fix_pathinfo = 1"/' /etc/php5/cgi/php.ini
sed -i 's/"#"/";"/' /etc/php5/conf.d/imap.ini
sed -i 's/"#"/";"/' /etc/php5/conf.d/mcrypt.ini


# PEAR modules
pear install I18N;
pear install -f System_Daemon;


# install percona (modified MySQL)
gpg --keyserver hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A;
gpg -a --export CD2EFD2A | apt-key add -
echo deb http://repo.percona.com/apt lenny main >> /etc/apt/sources.list
echo deb-src http://repo.percona.com/apt lenny main >> /etc/apt/sources.list
apt-get update && apt-get -y install percona-server-server 


# source version control
apt-get -y install \
	subversion \
	subversion-tools \
	libapache2-svn;


# restart servers
/etc/init.d/apache2 restart
/etc/init.d/mysql restart


# tools
apt-get -y install \
	p7zip-full \
	ssl-cert \
	ntp \
	siege \
	nmap \
	byobu \
	htop;


# install brute force detection
cd /tmp
wget http://www.rfxn.com/downloads/bfd-current.tar.gz
tar xzvf bfd-current.tar.gz
cd bfd-1.4
./install.sh


# mail transfer agent
apt-get -y install postfix;


# done!
echo "Thank you for using The Build Script."; echo "If you have any suggestions, questions or bug reports please find us on GitHub."; echo "https://github.com/jakeasmith/Ubuntu-Server-Build-Script/"