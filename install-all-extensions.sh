#!/bin/bash

for phpver in php-5.2.17 php-5.3.26; do
    echo "---------------------- Compiling extensions for $phpver"
#    ./install-ext.sh $phpver apc php-extensions/APC-3.1.13.tgz
#    ./install-ext.sh $phpver igbinary php-extensions/igbinary-1.1.1.tar.gz
#    ./install-ext.sh $phpver memcache php-extensions/memcache-2.2.7.tgz
    ./install-ext.sh $phpver xdebug php-extensions/xdebug-2.2.3.tgz
done
