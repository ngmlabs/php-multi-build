#!/bin/bash

VERSION=5.3.26
PREFIX=/opt/php/php-$VERSION
CORES=$(( `cat /proc/cpuinfo | grep '^processor' | wc -l` + 1 ))

# END_OF_CONFIG

FOLDER=php-$VERSION
PACKAGE=php-$VERSION.tar.bz2


[ -d $FOLDER ] &&  rm -rv $FOLDER
[ -f $PACKAGE ] || wget http://www.php.net/distributions/$PACKAGE
tar xvf $PACKAGE


function configure5_2 {
./configure \
        --prefix=$PREFIX \
        --with-config-file-path=$PREFIX/etc \
        --with-config-file-scan-dir=$PREFIX/etc/php.d \
        --with-layout=GNU \
        --disable-debug \
        --disable-cgi \
        --with-pic \
        --disable-rpath \
        --without-pear \
        --with-bz2 \
        --with-curl \
        --with-openssl \
        --with-gettext \
        --with-iconv \
        --with-pcre-regex \
        --with-zlib \
        --with-gmp \
        --without-sqlite \
        --enable-exif \
        --enable-ftp \
        --enable-sockets \
        --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-shmop \
        --with-mime-magic=/usr/share/file/magic.mime \
        --enable-wddx \
        --enable-calendar \
        --with-tidy \
        --enable-mbstring --enable-mbregex \
        --enable-bcmath \
        --with-xmlrpc \
        --enable-dom \
        --enable-soap \
        --enable-xmlreader --enable-xmlwriter \
        --with-pspell \
        --with-xsl \
        --enable-zip \
        --with-mcrypt \
        --with-mhash \
        --with-gd --with-png-dir=/usr --with-jpeg-dir=/usr --with-freetype-dir=/usr --enable-gd-native-ttf \
        --with-mysql \
        --with-mysqli \
        --with-pgsql \
        --enable-pdo \
        --with-pdo-mysql \
        --with-pdo-pgsql \
        --with-pdo-sqlite \
        --enable-pcntl=shared \
        --with-imap=shared --with-imap-ssl --with-kerberos \
        --with-apxs2
}


function configure5_3 {
# set this to 1 to compile with mysqlnd instead of libmysqlclient
WITH_MYSQLND=0

mysqlnd=''
[ $WITH_MYSQLND -ne 0 ] && mysqlnd='=mysqlnd'

./configure \
        --prefix=$PREFIX \
        --with-config-file-path=$PREFIX/etc \
        --with-config-file-scan-dir=$PREFIX/etc/php.d \
        --with-layout=GNU \
        --disable-debug \
        --disable-cgi \
        --with-pic \
        --disable-rpath \
        --without-pear \
        --with-bz2 \
        --with-curl \
        --with-openssl \
        --with-gettext \
        --with-iconv \
        --with-pcre-regex \
        --with-zlib \
        --with-gmp \
        --without-sqlite \
        --enable-exif \
        --enable-ftp \
        --enable-sockets \
        --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-shmop \
        --enable-wddx \
        --enable-calendar \
        --with-tidy \
        --enable-mbstring --enable-mbregex \
        --enable-bcmath \
        --with-xmlrpc \
        --enable-dom \
        --enable-soap \
        --enable-xmlreader --enable-xmlwriter \
        --with-pspell \
        --with-xsl \
        --enable-zip \
        --with-mcrypt \
        --with-mhash \
        --with-gd --with-png-dir=/usr --with-jpeg-dir=/usr --with-freetype-dir=/usr --enable-gd-native-ttf \
        --with-mysql$mysqlnd \
        --with-mysqli$mysqlnd \
        --with-pgsql \
        --enable-pdo$mysqlnd \
        --with-pdo-mysql \
        --with-pdo-pgsql \
        --with-pdo-sqlite \
        --enable-pcntl=shared \
        --with-imap=shared --with-imap-ssl --with-kerberos \
        --enable-intl \
        --with-apxs2
}


pushd $FOLDER

# Install extension modules in $PREFIX/usr/lib/php/modules.
EXTENSION_DIR=$PREFIX/lib/php/modules; export EXTENSION_DIR

case $VERSION in
    5.2.* )
        configure5_2
        ;;
    5.3.* )
        configure5_3
        ;;
    * )
        echo "You don't have a configure function for this version ($VERSION)"
        exit 1
esac

make -j$CORES

TMPFOLDER=`mktemp -d`

# trick apxs
mkdir -p $TMPFOLDER/etc/httpd/conf;
cp /etc/httpd/conf/httpd.conf $TMPFOLDER/etc/httpd/conf

make install INSTALL_ROOT=$TMPFOLDER

popd

# move httpd module along with php
mkdir -p $TMPFOLDER/$PREFIX/lib/httpd/modules
mv $TMPFOLDER/usr/lib/httpd/modules/libphp5.so $TMPFOLDER/$PREFIX/lib/httpd/modules

# generate ini file for each extension compiled
mkdir -p $TMPFOLDER/$PREFIX/etc/php.d
for extso in `ls $TMPFOLDER/$PREFIX/lib/php/modules`; do
    ext=${extso%%.so}
    echo ";extension=$extso" > $TMPFOLDER/$PREFIX/etc/php.d/$ext.ini
done

# move php to it's final destination
[ -d $PREFIX ] && { echo "Destination folder already exists. You'll have to move $TMPFOLDER/$PREFIX manually to $PREFIX"; exit 1; }
mkdir -p $PREFIX
mv $TMPFOLDER/$PREFIX/* $PREFIX
rm -rf $TMPFOLDER
