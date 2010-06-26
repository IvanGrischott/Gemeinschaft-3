#!/bin/bash

# (c) 2009-2010 AMOOMA GmbH - http://www.amooma.de
# Alle Rechte vorbehalten. -- All rights reserved.


#GEMEINSCHAFT_VERS="2.4.0"
#GEMEINSCHAFT_VERS="master-20100414-c9e268b"
GEMEINSCHAFT_VERS="3.0.0"
#GEMEINSCHAFT_TGZ_URL_DIR="http://www.amooma.de/gemeinschaft/download"
GEMEINSCHAFT_TGZ_URL_DIR="http://www.kempgen.net/tmp/gemeinschaft-amooma"
# URL: ${GEMEINSCHAFT_TGZ_URL_DIR}/gemeinschaft-${GEMEINSCHAFT_VERS}.tgz

GEMEINSCHAFT_SIEMENS_VERS="trunk-r00358"
GEMEINSCHAFT_SIEMENS_TGZ_URL_DIR="http://www.amooma.de/gemeinschaft/download"
# URL: ${GEMEINSCHAFT_SIEMENS_TGZ_URL_DIR}/gemeinschaft-siemens-${GEMEINSCHAFT_SIEMENS_VERS}.tgz

GEMEINSCHAFT_SOUNDS_DE_WAV_VERS="current"
GEMEINSCHAFT_SOUNDS_DE_WAV_TGZ_URL_DIR="http://www.amooma.de/gemeinschaft/download"
# URL: ${GEMEINSCHAFT_SOUNDS_DE_WAV_TGZ_URL_DIR}/gemeinschaft-sounds-de-wav-${GEMEINSCHAFT_SOUNDS_DE_WAV_VERS}.tar.gz

#ASTERISK_SOUNDS_DE_ALAW_VERS="current"
ASTERISK_SOUNDS_DE_ALAW_TGZ_URL_DIR="http://www.amooma.de/asterisk/sprachbausteine"
# URL: ${ASTERISK_SOUNDS_DE_ALAW_TGZ_URL_DIR}/asterisk-core-sounds-de-alaw.tar.gz


# language
L2=`echo $LANG | head -c 2 | tr 'A-Z' 'a-z'`
if [ -z $L2 ]; then L2='xx'; fi


err()
{
	ERRMSG="$*"
	echo '' >&2
	echo '*****************************************************************' >&2
	echo '' >&2
	if [ "$L2" == "de" ]; then
		echo '  FEHLER!' >&2
	else
		echo '  ERROR!' >&2
	fi
	if [ ! -z "$ERRMSG" ]; then echo -e "$ERRMSG" >&2 ; fi
	echo '' >&2
	echo '*****************************************************************' >&2
	echo '' >&2
	exit 1
}

trap "(echo ''; echo '***** ABORTED!') >&2; exit 130" INT TERM QUIT HUP
trap "err; exit 1" ERR


# check system
#
if [ ! -e /etc/debian_version ]; then
	if [ "$L2" == "de" ]; then
		err "Ihr System ist kein Debian."
	else
		err "Your system is not Debian."
	fi
fi
if [ "`id -un`" != "root" ]; then
	if [ "$L2" == "de" ]; then
		err "Dieses Skript muss als Benutzer \"root\" ausgeführt werden."
	else
		err "This script must be run as user \"root\"."
	fi
fi

if ( ! cat /etc/debian_version | head -n 1 | grep '^6.'      1>>/dev/null ) \
&& ( ! cat /etc/debian_version | head -n 1 | grep 'squeeze'  1>>/dev/null )
then
	if [ "$L2" == "de" ]; then
		err "  Ihr Debian ist nicht Version 6 (\"Squeeze\").\n" \
			"  Bitte laden Sie einen Debian-Installer herunter:\n" \
			"  http://cdimage.debian.org/cdimage/daily-builds/squeeze_d-i/current/"
	else
		err "  Your Debian is not version 6 (\"Squeeze\").\n" \
			"  Please download a Debian installer from\n" \
			"  http://cdimage.debian.org/cdimage/daily-builds/squeeze_d-i/current/"
	fi
fi


# set PATH
#
export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:${PATH}"


# list of SourceForge mirrors:
#SOURCEFORGE_MIRRORS=""
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://downloads.sourceforge.net/sourceforge"       #
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://mesh.dl.sourceforge.net/sourceforge"         # de
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://dfn.dl.sourceforge.net/sourceforge"          # de
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://switch.dl.sourceforge.net/sourceforge"       # ch
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://puzzle.dl.sourceforge.net/sourceforge"       # ch
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://surfnet.dl.sourceforge.net/sourceforge"      # nl
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://kent.dl.sourceforge.net/sourceforge"         # uk
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://internap.dl.sourceforge.net/sourceforge"     # us
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://superb-west.dl.sourceforge.net/sourceforge"  # us
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://superb-east.dl.sourceforge.net/sourceforge"  # us
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://garr.dl.sourceforge.net/sourceforge"         # it
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://heanet.dl.sourceforge.net/sourceforge"       # ie
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://optusnet.dl.sourceforge.net/sourceforge"     # au
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://ufpr.dl.sourceforge.net/sourceforge"         # br
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://jaist.dl.sourceforge.net/sourceforge"        # jp
#SOURCEFORGE_MIRRORS="${SOURCEFORGE_MIRRORS} http://nchc.dl.sourceforge.net/sourceforge"         # tw


# setup basic stuff
#
clear
echo ""
echo "***         Now we start to install and setup stuff we need for"
echo "***         Gemeinschaft. Better get yourself a cup of coffee."
cat <<\HEREDOC

                   )
                  (
                      )
              ,.----------.
             ((|          |
            .--\          /--.
           '._  '========'  _.'
              `""""""""""""`

HEREDOC
#sleep 1

#echo "***"
#echo "***  Setting up basic stuff ..."
#echo "***"
type apt-get 1>>/dev/null 2>>/dev/null
type aptitude 1>>/dev/null 2>>/dev/null || apt-get -y install aptitude
#APTITUDE_INSTALL="aptitude -y --allow-new-upgrades --allow-new-installs install"
APTITUDE_INSTALL="aptitude -y"
APTITUDE_REMOVE="aptitude -y purge"
APTITUDE_INSTALL="${APTITUDE_INSTALL} --allow-new-upgrades --allow-new-installs"
APTITUDE_INSTALL="${APTITUDE_INSTALL} install"
#echo "APTITUDE_INSTALL = ${APTITUDE_INSTALL}"


# very cheap hack to wait for the DHCP-client
#
COUNTER=0
while [  $COUNTER -lt 10 ]; do
    echo -n "."
    sleep 1
    let COUNTER=COUNTER+1 
done
echo ""


# update package lists
#
echo ""
echo "***"
echo "***  Updating package lists ..."
echo "***"
aptitude update


# install and configure local nameserver
#
echo ""
echo "***"
echo "***  Installing local caching nameserver ..."
echo "***"
if ( ! which named 1>>/dev/null 2>>/dev/null ); then
	echo "***  Installing bind9 ..."
	${APTITUDE_INSTALL} bind9
fi
if [ ! -e /etc/init.d/bind9 ]; then
	echo "***  Installing bind9 ..."
	${APTITUDE_INSTALL} bind9
fi

${APTITUDE_INSTALL} dnsutils
# install dnsutils so we can use dig later
#aptitude clean

if [ -e /etc/resolv.conf ]; then
	if [[ `grep -Ee "^nameserver[ \t]+" /etc/resolv.conf | head -n 1 | grep -Ee "127\.0\.0\.1"` ]]; then
		echo "nameserver 127.0.0.1 already configured."
	else
		[ -e /tmp/resolv.conf ] && rm -f /tmp/resolv.conf || true
		echo "nameserver 127.0.0.1" > /tmp/resolv.conf
		cat /etc/resolv.conf >> /tmp/resolv.conf
		mv -fT /tmp/resolv.conf /etc/resolv.conf
	fi
	if [ -e /etc/bind/named.conf.local ]; then
		if [ -e /etc/bind/zones.rfc1918 ]; then
			if [[ `grep "^include" /etc/bind/named.conf.local | grep "zones\.rfc1918"` ]]; then
				echo "/etc/bind/named.conf.local already includes /etc/bind/zones.rfc1918"
			else
				echo 'include "/etc/bind/zones.rfc1918";' >> /etc/bind/named.conf.local
			fi
			if [[ `grep "OPTIONS" /etc/default/bind9 | grep -e "-4"` ]]; then
				echo "/etc/default/bind9 already has -4 option for named."
			else
				sed -i 's/OPTIONS.*/OPTIONS="-4 -u bind"/' /etc/default/bind9
			fi
		fi
	fi
	/etc/init.d/bind9 restart || true
fi

# try to fill the DNS cache to speed up things later:
for server in \
  "www.amooma.de" \
  "www.amooma.com" \
  "www.gemeinschaft.de" \
  "downloads.digium.com" \
  "downloads.asterisk.org" \
  "downloads.sourceforge.net" \
  "0.debian.pool.ntp.org" \
  "1.debian.pool.ntp.org" \
  "ftp.de.debian.org" \
  "security.debian.org" \
  "ftp.debian.org" \
  "ftp.sangoma.com" \
  "example.com" \
  "example.net" \
  "example.org" \
; do
    dig +short ${server} >>/dev/null 2>>/dev/null &
    sleep 0.01 2>>/dev/null || true
done
sleep 1


# wait for internet access
#
echo "Checking Internet access ..."
while ! ( wget -O - -T 30 http://www.amooma.de/ >>/dev/null ); do sleep 5; done
MY_MAC_ADDR=`LANG=C ifconfig | grep -oE '[0-9a-fA-F]{1,2}\:[0-9a-fA-F]{1,2}\:[0-9a-fA-F]{1,2}\:[0-9a-fA-F]{1,2}\:[0-9a-fA-F]{1,2}\:[0-9a-fA-F]{1,2}' | head -n 1`
wget -O - -T 30 --spider http://www.amooma.de/gemeinschaft/installer/checkin?mac=$MY_MAC_ADDR >>/dev/null 2>>/dev/null || true


# install basic stuff
#
echo ""
echo "***"
echo "***  Installing basic stuff ..."
echo "***"
${APTITUDE_INSTALL} \
	coreutils lsb-base grep findutils sudo wget curl cron \
	expect dialog logrotate hostname net-tools ifupdown iputils-ping netcat \
	openssh-client openssh-server \
	udev psmisc dnsutils iputils-arping pciutils bzip2 \
	console-data console-tools \
	vim less
#aptitude clean

# now that we have vim, enable syntax highlighting by default:
if ( which vim 1>>/dev/null 2>>/dev/null ); then
	sed -i -r -e 's/^"(syntax) on/\1 on/' /etc/vim/vimrc || true
fi

# set EDITOR to "vim"
if ( which vim 1>>/dev/null 2>>/dev/null ); then
	echo "" >> /root/.bashrc || true
	echo "export EDITOR=\"vim\"" >> /root/.bashrc || true
	echo "" >> /root/.bashrc || true
	#if [ "x${SHELL}" = "x/bin/bash" ]; then
	#	source /root/.bashrc
	#fi
fi

# and add ls colors and some useful bash aliases:
cat <<\HEREDOC >> /root/.bashrc

export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias l='ls $LS_OPTIONS -lF'
alias ll='ls $LS_OPTIONS -lFA'

HEREDOC
#if [ "x${SHELL}" = "x/bin/bash" ]; then
#	source /root/.bashrc
#fi

WGET="wget"
WGET_ARGS="-c -T 60 --no-check-certificate"
DOWNLOAD="${WGET} ${WGET_ARGS}"


# set up lang enviroment
#
echo ""
echo "***"
echo "***  Setting up language environment ..."
echo "***"
${APTITUDE_INSTALL} locales
if [ -e /etc/locale.gen ]; then
	grep -e "^de_DE\.UTF-8 UTF-8" /etc/locale.gen || echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
	grep -e "^en_US\.UTF-8 UTF-8" /etc/locale.gen || echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
fi
if ( type locale-gen 2>>/dev/null ); then
	locale-gen
else
	echo "WARNING: locale-gen not found!" >&2
fi


# install ntp
#
echo ""
echo "***"
echo "***  Installing NTP ..."
echo "***"
if ( ! which ntpd 1>>/dev/null 2>>/dev/null ); then
	${APTITUDE_INSTALL} ntp
fi
if ( ! which ntpdate 1>>/dev/null 2>>/dev/null ); then
	${APTITUDE_INSTALL} ntpdate
fi
/etc/init.d/ntp stop 2>>/dev/null || true
ntpdate 0.debian.pool.ntp.org || true
ntpdate 1.debian.pool.ntp.org || true
/etc/init.d/ntp start || true
sleep 3


# make /var/run/ available as a ram file system (tmpfs).
#
sed -i -r -e 's/^(RAMRUN=)no/\1yes/' /etc/default/rcS || true


# install dahdi (//FIXME - do we need Dahdi? it requires a build
# environment!)
#
echo ""
echo "***"
echo "***  Installing Dahdi ..."
echo "***"
${APTITUDE_INSTALL} dahdi dahdi-modules
if [ ! -e /lib/modules/`uname -r`/dahdi/dahdi.ko ]; then
	${APTITUDE_INSTALL} dahdi-source
	echo ""
	echo "***"
	echo "***  Building Dahdi drivers ..."
	echo "***"
	m-a a-i -i -f dahdi
	# now we have dahdi-modules-`uname -r` (e.g. dahdi-modules-2.6.32-3-686)
	# which provides dahdi-modules
	# /lib/modules/`uname -r`/dahdi/...
	aptitude -y markauto dahdi-source \
		linux-headers-`uname -r` linux-kernel-headers
	#aptitude -y markauto debhelper module-assistant
	aptitude clean
fi

# generate /etc/dahdi/system.conf:
dahdi_genconf || true


# install libpri, asterisk, asterisk-chan-capi
#
echo ""
echo "***"
echo "***  Installing Asterisk ..."
echo "***"
${APTITUDE_INSTALL} libpri1.4 asterisk \
	asterisk-chan-capi asterisk-mysql \
	vpb-driver-source-
# asterisk depends on libvpb0 which recommends vpb-driver-source.
# Don't install that because that in turn pulls a complete build
# environment.
aptitude clean


# create directory for call-files
#
mkdir -p /var/spool/asterisk/outgoing
chmod a+rwx /var/spool/asterisk/outgoing
chmod a+rwx /var/spool/asterisk/tmp

# sudo permissions for Asterisk
#
echo "asterisk  ALL=(ALL)  NOPASSWD: ALL" > /etc/sudoers.d/gemeinschaft-asterisk
chmod 0440 /etc/sudoers.d/gemeinschaft-asterisk


# install lame
#
if ( ! which lame 1>>/dev/null 2>>/dev/null ); then
	echo ""
	echo "***"
	echo "***  Installing Lame ..."
	echo "***"
	echo 'deb http://www.debian-multimedia.org squeeze main non-free' \
		> /etc/apt/sources.list.d/debian-multimedia.list
	aptitude update --allow-untrusted || true
	${APTITUDE_INSTALL} --allow-untrusted debian-multimedia-keyring || true
	#${APTITUDE_INSTALL} lame || true
	${APTITUDE_INSTALL} --allow-untrusted lame || true
fi


# install misc packages
#
echo ""
echo "***"
echo "***  Installing other packages ..."
echo "***"
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
${APTITUDE_INSTALL} \
	perl perl-modules libnet-daemon-perl libnet-netmask-perl libio-interface-perl libio-socket-multicast-perl \
	sipsak \
	mysql-client mysql-server \
	apache2 \
	php5-cli libapache2-mod-php5 php5-mysql php5-ldap \
	sox mpg123
#aptitude clean


# install German voice prompts for Asterisk
#
echo ""
echo "***"
echo "***  Installing German voice prompts for Asterisk ..."
echo "***"

cd /usr/share/asterisk/sounds/
[ -e de ] && rm -rf de || true
${DOWNLOAD} "${ASTERISK_SOUNDS_DE_ALAW_TGZ_URL_DIR}/asterisk-core-sounds-de-alaw.tar.gz"
tar -xzf asterisk-core-sounds-de-alaw.tar.gz
rm -f asterisk-core-sounds-de-alaw.tar.gz


# install music on hold (MOH) for Asterisk
#
echo ""
echo "***"
echo "***  Installing music on hold (MOH) for Asterisk ..."
echo "***"

#cd /var/lib/asterisk/moh/
cd /usr/share/asterisk/moh/
for fmt in alaw; do
	#F=asterisk-moh-freeplay-${fmt}
	F=asterisk-moh-opsound-${fmt}-current
	wget http://downloads.asterisk.org/pub/telephony/sounds/${F}.tar.gz
	tar -xzf ${F}.tar.gz
	rm ${F}.tar.gz
done


# install Gemeinschaft
#
echo ""
echo "***"
echo "***  Installing Gemeinschaft ..."
echo "***"
cd /opt/
${DOWNLOAD} "${GEMEINSCHAFT_TGZ_URL_DIR}/gemeinschaft-${GEMEINSCHAFT_VERS}.tgz"
# check if the tarball conforms to the expected format:

NUM_DIRS_IN_TARBALL=`tar --list -f gemeinschaft-${GEMEINSCHAFT_VERS}.tgz | cut -d '/' -f 1 | uniq | wc -l`
if [ "x${NUM_DIRS_IN_TARBALL}" != "x1" ]; then
	ERRMSG="Gemeinschaft tarball contains more than one directory!"
	err
fi
echo "Gemeinschaft tarball contains exactly one top-level entry. Good."
TARBALL_TOP_LEVEL_DIR=`tar --list -f gemeinschaft-${GEMEINSCHAFT_VERS}.tgz | head -n 1 | cut -d '/' -f 1`
if [ "${TARBALL_TOP_LEVEL_DIR}x" != "gemeinschaft-${GEMEINSCHAFT_VERS}x" ]; then
	ERRMSG="Top-level directory in Gemeinschaft tarball has to be \"gemeinschaft-${GEMEINSCHAFT_VERS}\" but is \"${TARBALL_TOP_LEVEL_DIR}\"!"
	err
fi
echo "Gemeinschaft tarball contains ${TARBALL_TOP_LEVEL_DIR}. Good."
tar -xvzf gemeinschaft-${GEMEINSCHAFT_VERS}.tgz
rm -f gemeinschaft-${GEMEINSCHAFT_VERS}.tgz
mv gemeinschaft-${GEMEINSCHAFT_VERS} gemeinschaft-source-${GEMEINSCHAFT_VERS}
ln -snf gemeinschaft-source-${GEMEINSCHAFT_VERS} gemeinschaft-source

# main Gemeinschaft dir link
#
cd /opt/
ln -snf gemeinschaft-source/opt/gemeinschaft gemeinschaft

# fix MOH location for Debian:
#
sed -i -r -e 's#^( *;? *directory *= *)/var/lib/asterisk(/moh)#\1/usr/share/asterisk\2#g' /opt/gemeinschaft/etc/asterisk/musiconhold.conf

# voice prompts for Gemeinschaft
#
echo "Downloading Voiceprompts for Gemeinschaft ..."
[ -e /opt/gemeinschaft/sounds ]
cd /opt/gemeinschaft/sounds
if [ -e de-DE ]; then
	rm -rf de-DE || true
fi
if [ -e de-DE-tts ]; then
	rm -rf de-DE-tts || true
fi
${DOWNLOAD} "${GEMEINSCHAFT_SOUNDS_DE_WAV_TGZ_URL_DIR}/gemeinschaft-sounds-de-wav-${GEMEINSCHAFT_SOUNDS_DE_WAV_VERS}.tar.gz"
tar -xzf gemeinschaft-sounds-de-wav-${GEMEINSCHAFT_SOUNDS_DE_WAV_VERS}.tar.gz
rm -f gemeinschaft-sounds-de-wav-${GEMEINSCHAFT_SOUNDS_DE_WAV_VERS}.tar.gz || true
if [ -e de-DE ]; then
	mv de-DE de-DE-tts
fi
if [ -e de-DE-tts ]; then
	ln -snf de-DE-tts de-DE
fi
cd de-DE-tts
#/opt/gemeinschaft/sbin/sounds-wav-to-alaw.sh || true
# //FIXME: "sox: invalid option -- w"
# see man sox. -b 16 ? -b 8 ?
#rm *.wav || true
cd


# MySQL: add gemeinschaft user
#
echo ""
echo "***"
echo "***  Creating Gemeinschaft database ..."
echo "***"
GEMEINSCHAFT_DB_PASS=`head -c 20 /dev/urandom | md5sum -b - | cut -d ' ' -f 1 | head -c 30`
[ -e /tmp/mysql-gemeinschaft-grant.sql ] && rm -f /tmp/mysql-gemeinschaft-grant.sql || true
touch /tmp/mysql-gemeinschaft-grant.sql
chmod go-rwx /tmp/mysql-gemeinschaft-grant.sql
echo "GRANT ALL ON \`asterisk\`.* TO 'gemeinschaft'@'localhost' IDENTIFIED BY '${GEMEINSCHAFT_DB_PASS}';" >> /tmp/mysql-gemeinschaft-grant.sql
echo "GRANT ALL ON \`asterisk\`.* TO 'gemeinschaft'@'%' IDENTIFIED BY '${GEMEINSCHAFT_DB_PASS}';" >> /tmp/mysql-gemeinschaft-grant.sql
echo "FLUSH PRIVILEGES;" >> /tmp/mysql-gemeinschaft-grant.sql
cat /tmp/mysql-gemeinschaft-grant.sql | mysql --batch
rm -f /tmp/mysql-gemeinschaft-grant.sql
mysql --batch --user=gemeinschaft --password="${GEMEINSCHAFT_DB_PASS}" -e "SELECT 'test'" > /dev/null

# Gemeinschaft database
#
cd /opt/gemeinschaft-source/usr/share/doc/gemeinschaft/
sed -i -e 's/DEFINER *= *[^ ]*/DEFINER=CURRENT_USER()/g' asterisk.sql
mysql --batch --user=gemeinschaft --password="${GEMEINSCHAFT_DB_PASS}" < asterisk.sql
cd


# Apache configuration
#
echo ""
echo "***"
echo "***  Setting up Apache web server ..."
echo "***"
cd /etc/apache2/conf.d/
ln -snf /opt/gemeinschaft-source/etc/apache2/conf.d/gemeinschaft.conf gemeinschaft.conf
if [ -e /opt/gemeinschaft-source/etc/apache2/sites-available/gemeinschaft ]; then
	cd /etc/apache2/sites-available/
	ln -snf /opt/gemeinschaft-source/etc/apache2/sites-available/gemeinschaft gemeinschaft
	a2dissite default
	a2ensite gemeinschaft
else
	cd /etc/apache2/sites-available/
	cat default | sed -e 's/AllowOverride None/AllowOverride All/i' > gemeinschaft
	a2dissite default
	a2ensite gemeinschaft
fi
a2enmod rewrite
a2enmod alias
a2enmod mime
a2enmod php5
a2enmod headers || true


# PHP-APC
#
echo ""
#echo "***"
#echo "***  Installing PHP-APC ..."
#echo "***"
#${APTITUDE_INSTALL} php-apc
#//FIXME - not (yet?) available

/etc/init.d/apache2 stop
invoke-rc.d apache2 restart

# sudo permissions for Apache
#
echo "www-data  ALL=(ALL)  NOPASSWD: ALL" > /etc/sudoers.d/gemeinschaft-apache
chmod 0440 /etc/sudoers.d/gemeinschaft-apache


# configure Asterisk
#
echo ""
echo "***"
echo "***  Setting up Gemeinschaft ..."
echo "***"
cd /etc/
mv asterisk asterisk.DEBIAN
ln -snf /opt/gemeinschaft-source/etc/asterisk

# Replace astdatadir "/var/lib/asterisk" by "/usr/share/asterisk"
# (the default on Debian):
sed -i -r -e 's#^(astdatadir\s*).*#\1=> /usr/share/asterisk#' /etc/asterisk/asterisk.conf || true

# Replace astrundir "/var/run" by "/var/run/asterisk"
# (the default on Debian):
sed -i -r -e 's#^(astrundir\s*).*#\1=> /var/run/asterisk#' /etc/asterisk/asterisk.conf || true


# change owner of /opt/gemeinschaft/etc/asterisk/* to asterisk
chown -h -R asterisk:asterisk /opt/gemeinschaft/etc/asterisk


# configure Gemeinschaft
#
cd /etc/
#ln -snf /opt/gemeinschaft-source/etc/gemeinschaft
mkdir -p /etc/gemeinschaft
cd /etc/gemeinschaft
if [ ! -e gemeinschaft.php ]; then
	cp /opt/gemeinschaft-source/etc/gemeinschaft/gemeinschaft.php ./
fi
cp /opt/gemeinschaft-source/etc/gemeinschaft/.gemeinschaft-version ./  || true
mkdir -p /etc/gemeinschaft/asterisk
cd /etc/gemeinschaft/asterisk
cp -R /opt/gemeinschaft-source/etc/gemeinschaft/asterisk/* ./
if [ -e /etc/gemeinschaft/asterisk/manager.conf.d-available/phonesuite.conf ]; then
	AMI_PASS=`head -c 20 /dev/urandom | md5sum -b - | cut -d ' ' -f 1 | head -c 9`
	sed -i "s/^\(\s*secret\s*=\s*\)[^; \t]*\(.*\)/\1${AMI_PASS}\2/g" /etc/gemeinschaft/asterisk/manager.conf.d-available/phonesuite.conf
fi

# find IP address
# FIXME: Vielleicht geht das auch schoener.
#
MY_IP_ADDR=`LANG=C ifconfig | grep inet | grep -v 'inet6' | grep -v '127\.0\.0\.1' | head -n 1 | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -v '^255' | head -n 1`
if [ "x$?" != "x0" ] || [ -z ${MY_IP_ADDR} ]; then
	echo "***** Failed to find your IP address." 2>&1
	MY_IP_ADDR="192.168.1.130"
fi
MY_NETMASK=`LANG=C ifconfig | grep inet | grep -v 'inet6' | grep -v '127\.0\.0\.1' | head -n 1 | grep -io 'mask.*' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep '^255' | sort -n | head -n 1`
if [ "x$?" != "x0" ] || [ -z ${MY_NETMASK} ]; then
	echo "***** Failed to find your netmask." 2>&1
	MY_NETMASK="255.0.0.0"
fi

# configure gemeinschaft.php - IP address, DB password etc.
#
sed -i "s/\(^[\s#\/]*\$INSTALLATION_TYPE\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'single';/g" /etc/gemeinschaft/gemeinschaft.php


sed -i "s/\(^[\s#\/]*\$DB_MASTER_HOST\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'127.0.0.1';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i  "s/\(^[\s#\/]*\$DB_SLAVE_HOST\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'127.0.0.1';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i "s/\(^[\s#\/]*\$DB_MASTER_USER\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'gemeinschaft';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i  "s/\(^[\s#\/]*\$DB_SLAVE_USER\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'gemeinschaft';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i "s/\(^[\s#\/]*\$DB_MASTER_PWD\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'${GEMEINSCHAFT_DB_PASS}';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i  "s/\(^[\s#\/]*\$DB_SLAVE_PWD\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'${GEMEINSCHAFT_DB_PASS}';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i "s/\(^[\s#\/]*\$DB_MASTER_DB\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'asterisk';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i  "s/\(^[\s#\/]*\$DB_SLAVE_DB\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'asterisk';/g" /etc/gemeinschaft/gemeinschaft.php

sed -i "s/\(^[\s#\/]*\$PROV_HOST\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'${MY_IP_ADDR}';/g" /etc/gemeinschaft/gemeinschaft.php

sed -i "s/\(^[\s#\/]*\$CALL_INIT_FROM_NET\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'${MY_IP_ADDR}\/${MY_NETMASK}';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i "s/\(^[\s#\/]*\$MONITOR_FROM_NET\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'${MY_IP_ADDR}\/${MY_NETMASK}';/g" /etc/gemeinschaft/gemeinschaft.php

sed -i "s/\(^[\s#\/]*\$EMAIL_DELIVERY\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'sendmail';/g" /etc/gemeinschaft/gemeinschaft.php

sed -i "s/\(^[\s#\/]*\$LOG_GMT\s*=\s*\)[^a-z0-9]*\s*;/\1false;/g" /etc/gemeinschaft/gemeinschaft.php

sed -i "s/\(^[\s#\/]*\)\(\$FAX_ENABLED\s*=\s*\)\([A-Za-z0-9']\)*\s*;/\2true;/g" /etc/gemeinschaft/gemeinschaft.php
sed -i "s/\(^[\s#\/]*\)\(\$FAX_PREFIX\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\2'*96';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i "s/\(^[\s#\/]*\)\(\$FAX_TSI_PREFIX\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\2'';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i "s/\(^[\s#\/]*\)\(\$FAX_TSI\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\2 @\$CANONIZE_NATL_PREFIX.@\$CANONIZE_AREA_CODE.@\$CANONIZE_LOCAL_BRANCH.'0';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i "s/\(^[\s#\/]*\)\(\$FAX_HYLAFAX_HOST\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\2'127.0.0.1';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i "s/\(^[\s#\/]*\)\(\$FAX_HYLAFAX_PORT\s*=\s*\)\([0-9']\)*\s*;/\2 4559;/g" /etc/gemeinschaft/gemeinschaft.php

HFAXADM_PASS=`head -c 20 /dev/urandom | md5sum -b - | cut -d ' ' -f 1 | head -c 12`

sed -i "s/\(^[\s#\/]*\)\(\$FAX_HYLAFAX_ADMIN\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\2'hfaxadm';/g" /etc/gemeinschaft/gemeinschaft.php
sed -i "s/\(^[\s#\/]*\)\(\$FAX_HYLAFAX_PASS\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\2'${HFAXADM_PASS}';/g" /etc/gemeinschaft/gemeinschaft.php

sed -i -e 's/^\s*[^#].*//g' /opt/gemeinschaft/etc/listen-to-ip
( echo ; echo $MY_IP_ADDR ; echo ) >> /opt/gemeinschaft/etc/listen-to-ip

mysql --batch --user=gemeinschaft --password="${GEMEINSCHAFT_DB_PASS}" -e "USE \`asterisk\`; UPDATE \`hosts\` SET \`host\`='${MY_IP_ADDR}' WHERE \`id\`=1;" || true
mysql --batch --user=gemeinschaft --password="${GEMEINSCHAFT_DB_PASS}" -e "USE \`asterisk\`; UPDATE \`hosts\` SET \`host\`='${MY_IP_ADDR}';" || true

# moved gemeinschaft-siemens installing here cause gemeinschaft have to be configured before generating the SSL cert


# install gemeinschaft-siemens addon
#
echo "Downloading Siemens addon for Gemeinschaft (Openstage provisoning) ..."
cd /opt/
${DOWNLOAD} "${GEMEINSCHAFT_SIEMENS_TGZ_URL_DIR}/gemeinschaft-siemens-${GEMEINSCHAFT_SIEMENS_VERS}.tgz"
tar -xzf gemeinschaft-siemens-${GEMEINSCHAFT_SIEMENS_VERS}.tgz
rm -f gemeinschaft-siemens-${GEMEINSCHAFT_SIEMENS_VERS}.tgz
mv gemeinschaft-siemens-${GEMEINSCHAFT_SIEMENS_VERS} gemeinschaft-siemens-source-${GEMEINSCHAFT_SIEMENS_VERS}
ln -snf gemeinschaft-siemens-source-${GEMEINSCHAFT_SIEMENS_VERS} gemeinschaft-siemens-source
cd /opt/
ln -snf /opt/gemeinschaft-siemens-source/opt/gemeinschaft-siemens gemeinschaft-siemens
cd


# configure gemeinschaft-siemens
#
${APTITUDE_INSTALL} openssl 
a2enmod rewrite 
a2enmod ssl

cd /etc/apache2/
[ -e ssl ] && rm -rf ssl || true
ln -snf /opt/gemeinschaft-siemens-source/doc/etc-apache2-ssl ssl
cd /etc/apache2/ssl/
./gen-cert.sh >>/dev/null
chown root:root openstage-*.pem
chmod 640 openstage-*.pem
cd /etc/apache2/sites-available/
ln -snf /opt/gemeinschaft-siemens-source/doc/httpd-vhost.conf.example gemeinschaft-siemens
a2ensite gemeinschaft-siemens
cd


# documentation
#
cd /usr/share/doc
ln -snf /opt/gemeinschaft-source/usr/share/doc/gemeinschaft


# log dir
#
mkdir -p /var/log/gemeinschaft
chmod a+rwx /var/log/gemeinschaft


# logrotate rules
#
cd /etc/logrotate.d/
ln -snf /opt/gemeinschaft-source/etc/logrotate.d/asterisk
ln -snf /opt/gemeinschaft-source/etc/logrotate.d/gemeinschaft


# web dir
#
cd /var/www/
ln -snf /opt/gemeinschaft-source/var/www/gemeinschaft
ln -snf /opt/gemeinschaft-source/var/www/.htaccess


# misc
#
cd /var/lib/
ln -snf /opt/gemeinschaft-source/var/lib/gemeinschaft


# gs-sip-ua-config-responder fuer Snom
#
if [ -e /opt/gemeinschaft-source/etc/init.d/gs-sip-ua-config-responder ]; then
	cd /etc/init.d/
	ln -snf /opt/gemeinschaft-source/etc/init.d/gs-sip-ua-config-responder
	update-rc.d gs-sip-ua-config-responder defaults 92 8
	invoke-rc.d gs-sip-ua-config-responder start
fi


# cron jobs
#
cd /etc/cron.d/
ln -snf /opt/gemeinschaft-source/etc/cron.d/gs-cc-guardian || true
ln -snf /opt/gemeinschaft-source/etc/cron.d/gs-queuelog-to-db || true
ln -snf /opt/gemeinschaft-source/etc/cron.d/gs-queues-refresh || true


# remove build environment 
#
echo ""
echo "***"
echo "***  Removing build environment  ..."
echo "***"
aptitude -y markauto linux-headers-`uname -r` linux-kernel-headers
aptitude clean


# add /opt/gemeinschaft/scripts to PATH
#
echo "" >> /root/.bashrc || true
echo "export PATH=\"\$PATH:/opt/gemeinschaft/scripts\"" >> /root/.bashrc || true
echo "" >> /root/.bashrc || true
#if [ "x${SHELL}" = "x/bin/bash" ]; then
#	source /root/.bashrc
#fi


# motd
#
echo "***" > /etc/motd.static
echo "***    _____                                              _____" >> /etc/motd.static
echo "***   (.---.)       G E M E I N S C H A F T  ${GEMEINSCHAFT_VERS}       (.---.)" >> /etc/motd.static
echo "***    /:::\\ _.-----------------------------------------._/:::\\" >> /etc/motd.static
echo "***    -----                                              -----" >> /etc/motd.static
echo "***" >> /etc/motd.static
echo "***   Need help with Gemeinschaft? We have an excellent free mailinglist" >> /etc/motd.static
echo "***   and offer the best support and consulting money can buy. Have a" >> /etc/motd.static
echo "***   look at http://www.amooma.de/gemeinschaft/ for more information." >> /etc/motd.static
echo "***" >> /etc/motd.static
[ -e /etc/motd ] && rm -rf /etc/motd || true
ln -s /etc/motd.static /etc/motd


# fax installation starts here
#
HF_CONF_SRC="/usr/share/doc/gemeinschaft/misc/fax-integration"


echo ""
echo "***"
echo "***  Installing IAXmodem ..."
echo "***"
${APTITUDE_INSTALL} iaxmodem

# iaxmodem config
#
cp "${HF_CONF_SRC}/ttyIAX0" /etc/iaxmodem/ttyIAX0
cp "${HF_CONF_SRC}/ttyIAX1" /etc/iaxmodem/ttyIAX1

# add iaxmodem entries to iax.conf
#
cat "${HF_CONF_SRC}/iax.conf.template" >> /opt/gemeinschaft/etc/asterisk/iax.conf

# add faxgetty entries to inittab
# //FIXME? - set USE_FAXGETTY=yes or USE_FAXGETTY=init in
# /etc/default/hylafax instead?
#
echo "" >> /etc/inittab 
echo "# HylaFax getty" >> /etc/inittab
echo "mo00:23:respawn:/usr/sbin/faxgetty ttyIAX0" >> /etc/inittab
echo "mo01:23:respawn:/usr/sbin/faxgetty ttyIAX1" >> /etc/inittab
# adding these lines to /etc/inittab makes /etc/default/hylafax
# default to USE_FAXGETTY=init instead of USE_FAXGETTY=yes

# make init reload /etc/inittab
/sbin/init q


echo ""
echo "***"
echo "***  Installing HylaFax ..."
echo "***"
# hylafax-server (/usr/sbin/faxsetup) needs /usr/sbin/sendmail but
# does not depend on mail-transfer-agent
${APTITUDE_INSTALL} postfix
${APTITUDE_INSTALL} hylafax-server

if [ ! -e /etc/hylafax/getty-link ]; then
	ln -sn /usr/sbin/faxgetty /etc/hylafax/getty-link
fi

# make tmp directory world accessible
chmod 777 /var/spool/hylafax/tmp/

# sudo permissions for FaxDispatch
#
echo "uucp ALL = NOPASSWD: /bin/chgrp" > /etc/sudoers.d/gemeinschaft-hylafax
chmod 0440 /etc/sudoers.d/gemeinschaft-hylafax

# run HylaFax config script
#
#/usr/sbin/faxsetup -nointeractive
# is run automatically by post-install script of hylafax-server

# fax modem config
#
cp "${HF_CONF_SRC}/config.ttyIAX0" /var/spool/hylafax/etc/config.ttyIAX0
cp "${HF_CONF_SRC}/config.ttyIAX0" /var/spool/hylafax/etc/config.ttyIAX1

# fax daemon config
#
cp "${HF_CONF_SRC}/hfaxd.conf" /etc/hylafax/hfaxd.conf

# fax dispatch config
#
cp "${HF_CONF_SRC}/FaxDispatch" /var/spool/hylafax/etc/

# make hylafax run on boot
#
sed -i -r -e 's/^ *# *(RUN_HYLAFAX)=.*/\1=1/g' /etc/default/hylafax


# delete example users, queues etc.
#
for user in "anna" "hans" "lisa" "peter"; do
	/opt/gemeinschaft/scripts/gs-user-del --user="${user}" || true
done
for queue in "5000"; do
	/opt/gemeinschaft/scripts/gs-queue-del --queue="${queue}" || true
done
mysql --batch --user=gemeinschaft --password="${GEMEINSCHAFT_DB_PASS}" -e \
	"USE \`asterisk\`; DELETE FROM \`phones\`;" 1>>/dev/null 2>>/dev/null || true


# Add sample admin and user
#

ADMIN_NAME="admin"
ADMIN_FNAME="System"
ADMIN_LNAME="Administrator"
ADMIN_EXTEN="9999"
let "PIN = $RANDOM % 9999"
ADMIN_PIN=`printf "%04d\n" "$PIN"`

USER_NAME="user"
USER_FNAME="Ordinary"
USER_LNAME="User"
USER_EXTEN="9998"
let "PIN = $RANDOM % 9999"
USER_PIN=`printf "%04d\n" "$PIN"`

#TODO: Loop on error!

# Add admin account
/opt/gemeinschaft/scripts/gs-user-add \
	--user="$ADMIN_NAME" \
	--ext="$ADMIN_EXTEN" \
	--pin="$ADMIN_PIN" \
	--firstname="$ADMIN_FNAME" \
	--lastname="$ADMIN_LNAME" \
	--email="" \
	--host=1 || true

# Add user account
/opt/gemeinschaft/scripts/gs-user-add \
	--user="$USER_NAME" \
	--ext="$USER_EXTEN" \
	--pin="$USER_PIN" \
	--firstname="$USER_FNAME" \
	--lastname="$USER_LNAME" \
	--email="" \
	--host=1 || true


# add admin to GUI_SUDO_ADMINS:
#sed -i "s/\(^[\s#\/]*\$GUI_SUDO_ADMINS\s*=\s*\)\([\"']\)[^\"']*[\"']\s*;/\1'${ADMIN_NAME}';/g" /etc/gemeinschaft/gemeinschaft.php
# add "admin" account in group system:
/opt/gemeinschaft/scripts/gs-group-member-add --group admins --member $ADMIN_NAME


# get SIP passwords:

ADMIN_SIPPW=$( mysql --user=gemeinschaft --password=${GEMEINSCHAFT_DB_PASS} -h localhost -D asterisk -A -B --raw -N -s -s -s -e "SELECT \`secret\` FROM \`ast_sipfriends\` WHERE \`name\`='$ADMIN_EXTEN'" | awk  '{print $1}' );
if [ -z $ADMIN_SIPPW ]; then ADMIN_SIPPW='x'; fi

USER_SIPPW=$( mysql --user=gemeinschaft --password=${GEMEINSCHAFT_DB_PASS} -h localhost -D asterisk -A -B --raw -N -s -s -s -e "SELECT \`secret\` FROM \`ast_sipfriends\` WHERE \`name\`='$USER_EXTEN'" | awk  '{print $1}' );
if [ -z $ADMIN_SIPPW ]; then USER_SIPPW='x'; fi



echo ""
echo "***"
echo "***  Restarting services ..."
echo "***"

/etc/init.d/hylafax stop  || true
/etc/init.d/iaxmodem stop || true

/etc/init.d/asterisk stop || true
/etc/init.d/dahdi stop || true
/opt/gemeinschaft/sbin/gs-ast-dialplan-gen

# start services
#
invoke-rc.d hylafax start  || true
invoke-rc.d iaxmodem start || true
invoke-rc.d dahdi start    || true
invoke-rc.d asterisk start || true

dmesg | grep -i dahdi || true


# updating authentication file
#
/opt/gemeinschaft/sbin/gs-hylafax-auth-update || true


# check out
#
wget -O - -T 30 --spider "http://www.amooma.de/gemeinschaft/installer/checkout?mac=$MY_MAC_ADDR" >>/dev/null 2>>/dev/null || true


logger "Gemeinschaft ${GEMEINSCHAFT_VERS} has just been installed."


# warning
#
clear
echo "Security Warning"
echo "================"
echo ""
echo "Never ever run this system outside of a safe intranet "
echo "environment without doing some serious security auditing!"
echo "See /etc/gemeinschaft/gemeinschaft.php"
echo ""


# let's do some ASCII art
#
(
clear
echo "**************************************************************************"
echo "***                 G E M E I N S C H A F T   ${GEMEINSCHAFT_VERS}"
echo "***"
echo "***   Use your admin account \"${ADMIN_NAME}\" and PIN \"${ADMIN_PIN}\" to log into the GUI at"
echo "***     http://${MY_IP_ADDR}/gemeinschaft/"
echo "***"
echo "***   Use these SIP accounts to setup your first two phones:"
echo "***"
echo "***                      (.---.)                 (.---.)"
echo "***                       /:::\\ _.--------------._/:::\\"
echo "***                       -----                   -----"
echo "***"
echo "***     SIP Username :    $(printf "% -5s" $ADMIN_EXTEN)                   $(printf "% -5s" $USER_EXTEN)"
echo "***     SIP Password :    $(printf "% -20s" $ADMIN_SIPPW)    $(printf "% -20s" $USER_SIPPW)"
echo "***     SIP Server   :    $(printf "% -15s" $MY_IP_ADDR)         $(printf "% -15s" $MY_IP_ADDR)"
echo "***"
echo "***   Find mailinglists and more info at"
echo "***     http://www.amooma.de/gemeinschaft/"
echo "**************************************************************************"
)


# make bash re-read .bashrc:
#
if [ "x${SHELL}" = "x/bin/bash" ]; then
	exec ${SHELL}
fi
exit 0


