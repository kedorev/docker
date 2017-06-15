#!/bin/bash

apt-get install -y -qq wget
rm /usr/local/apache2/htdocs/index.html
wget https://www.adminer.org/static/download/4.2.5/adminer-4.2.5.php /usr/local/apache2/htdocs/index.html