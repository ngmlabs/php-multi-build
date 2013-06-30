#!/bin/bash

BUILDDIR="./extbuild"
PHPBASE="/opt/php"

[ $# -eq 3 ] || { echo -e "Syntax: $0 <PHPID> <extension_name> <extension_source>\n    PHPID is the name of your PHP folder in /opt/php (eg. PHPID=php-5.3.26 for $PHPBASE/php-5.3.26)"; exit 1; }

PHPID=$1
EXTNAME=$2
EXTSRC=$3

[ -d "/opt/php/$PHPID" ] || { echo "PHP folder not found (/opt/php/$PHPID)"; exit 1; }
[ -f "$EXTSRC" ] || { echo "File not found ($EXTSRC)"; exit 1; }

[ -d "$BUILDDIR" ] && { rm -rf $BUILDDIR; }
mkdir -p $BUILDDIR

tar xvf $EXTSRC -C $BUILDDIR

EXT=`basename $EXTSRC`
EXT=${EXT%%.tar.gz}
EXT=${EXT%%.tar.bz2}
EXT=${EXT%%.tgz}

PREFIX=$PHPBASE/$PHPID
EXTSRC=$(readlink -f $EXTSRC)
EXTSRCDIR=`dirname $EXTSRC`

[ -d "$BUILDDIR/$EXT" ] || { echo "Could not determine extension folder."; exit 1; }

pushd $BUILDDIR/$EXT

$PREFIX/bin/phpize
./configure --with-php-config=$PREFIX/bin/php-config
make
[ $? -eq 0 ] || { echo "Extension compilation error. Check the messages above."; exit 2; }

# install extension
strip ./modules/$EXTNAME.so
mv ./modules/$EXTNAME.so $PREFIX/lib/php/modules

# install ini file
echo $EXTSRCDIR
if [ -f $EXTSRCDIR/$EXTNAME.ini ]; then
    cp $EXTSRCDIR/$EXTNAME.ini $PREFIX/etc/php.d/$EXTNAME.ini
#    sed -i -e "s/%%php_module_path%%/$PREFIX\/lib\/php\/modules/g" $PREFIX/etc/php.d/$EXTNAME.ini
else
    echo "extension=$EXTNAME.so" > $PREFIX/etc/php.d/$EXTNAME.ini
fi

popd $BUILDDIR
