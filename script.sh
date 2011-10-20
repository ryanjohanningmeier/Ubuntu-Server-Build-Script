#!/bin/bash

# https://forums.mediatemple.net/viewtopic.php?id=5204
mkdir /root/tmp
chmod 777 /root/tmp
mount --bind /root/tmp /tmp
mount --bind /root/tmp /var/tmp

# fix an ldconfig error
# https://bugs.launchpad.net/ubuntu/+source/gcc-3.3/+bug/40285
echo "/lib" >> /etc/ld.so.conf.d/libc.conf
ldconfig

# set time
dpkg-reconfigure tzdata;

# initial updates
apt-get update && apt-get -y dist-upgrade;

# must have
apt-get -y install \
	build-essential \
	checkinstall \
	autogen \
	gcc \
	make \
	zlib1g-dev \ 
	libmysql++-dev;

# security and monitoring
apt-get -y install munin-node;
apt-get -y install nagios-nrpe-server;
apt-get -y install ufw;
# apt-get -y install denyhosts;
# sed -i 's/"PURGE_DENY ="/"PURGE_DENY = 24w"/' /etc/denyhosts.conf
# sed -i 's/"ADMIN_EMAIL = root@localhost"/"ADMIN_EMAIL = servers@cliks.co"/' /etc/denyhosts.conf
# ufw disable
# ufw logging on && ufw allow 22 && ufw allow 80 && ufw allow 443
# ufw enable

# UFW seems to neglect adding rules allowing local connections to
# (http://wwww.ubuntuforums.org/showthread.php?t=1409860)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT


# apache2 and php
apt-get -y install \
	apache2 \
	apache2-threaded-dev \
	apache2-mpm-prefork \
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
	php-soap \
	php-apc \
	postfix;

# configure apache
ulimit -s 256
a2enmod alias deflate status rewrite php5 ssl;
a2dismod negotiation authn_file authz_default authz_groupfile;

chmod -R a+x,g+x /var/www/
chown -R www-data.www-data /var/www/

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

# PECL GeoIP extension
# cd /tmp
# wget http://geolite.maxmind.com/download/geoip/api/c/GeoIP.tar.gz
# tar xzvf GeoIP.tar.gz
# cd GeoIP-1.4.6
# ./configure
# make
# make check
# make install
# pecl install geoip
# echo "; configuration for php GeoIP module
# extension=geoip.so" > /etc/php5/conf.d/geoip.ini


# install percona
gpg --keyserver hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A;
gpg -a --export CD2EFD2A | apt-key add -

echo deb http://repo.percona.com/apt lenny main >> /etc/apt/sources.list
echo deb-src http://repo.percona.com/apt lenny main >> /etc/apt/sources.list
apt-get update && apt-get -y install percona-server-server 
#percona-server-client percona-server-common libmysqlclient-dev;
	
	# libmysqlclient-dev - Percona SQL database development files
	# libmysqlclient15-dev - Percona Server database development files - empty transitional package
	# libmysqlclient16 - Percona SQL database client library
	# libpercona-xtradb-client-dev - Percona SQL database development files
	# libpercona-xtradb-client15-dev - Percona SQL database development files - empty transitional package
	# libpercona-xtradb-client16 - Percona SQL database client library
	# percona-server-client - Percona Server database client (metapackage depending on the latest version)
	# percona-server-common - Percona Server database common files (e.g. /etc/mysql/my.cnf)
	# percona-server-server - Percona Server database server (metapackage depending on the latest version)
	# percona-sql-client - MySQL database client (metapackage depending on the latest version)
	# percona-sql-client-5.0 - MySQL database client binaries
	# percona-sql-common - MySQL database common files
	# percona-sql-server - MySQL database server (metapackage depending on the latest version)
	# percona-sql-server-5.0 - MySQL database server binaries
	# percona-xtradb-client - Percona SQL database client (metapackage depending on the latest version)
	# percona-xtradb-client-5.1 - Percona SQL database client binaries
	# percona-xtradb-common - Percona SQL database common files (e.g. /etc/mysql/my.cnf)
	# percona-xtradb-server - Percona SQL database server (metapackage depending on the latest version)
	# percona-xtradb-server-5.1 - Percona SQL database server binaries

	
# sphinx
# cd /tmp;
# wget http://www.sphinxsearch.com/downloads/sphinx-0.9.9.tar.gz
# tar xzvf sphinx-0.9.9.tar.gz
# cd sphinx-0.9.9
# ./configure
# make
# make install

# tools
apt-get -y install p7zip-full subversion ssl-cert ntp subversion subversion-tools libapache2-svn siege nmap byobu htop



# install brute force detection
cd /tmp
wget http://www.rfxn.com/downloads/bfd-current.tar.gz
tar xzvf bfd-current.tar.gz
cd bfd-1.4
./install.sh

# geoip database setup
# cd /tmp
# mkdir /usr/local/share/GeoIP/
# wget -N -q http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
# gzip -d GeoLiteCity.dat.gz
# mv -f GeoLiteCity.dat /usr/local/share/GeoIP/GeoIPCity.dat
# wget -N -q http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
# gzip -d GeoIP.dat.gz
# mv -f GeoIP.dat /usr/local/share/GeoIP/GeoIP.dat


# restart servers
/etc/init.d/apache2 restart
/etc/init.d/mysql restart


# done!