#!/bin/bash

[ $# -eq 1 ] || { echo -e "Syntax: $0 <PHPID>\n    PHPID is the name of your PHP folder in /opt/php (eg. PHPID=php-5.3.26 for $PHPBASE/php-5.3.26)"; exit 1; }

PHPID=$1

[ -d "/opt/php/$PHPID" ] || { echo "PHP folder not found (/opt/php/$PHPID)"; exit 1; }

cat << EOF > /etc/httpd/conf.d/php.conf
LoadModule php5_module /opt/php/$PHPID/lib/httpd/modules/libphp5.so

AddHandler php5-script .php
AddType text/html .php

DirectoryIndex index.php
EOF
