#!/bin/bash

cd /var/www/brat/brat-v1.3_Crunchy_Frog && /var/www/brat/brat-v1.3_Crunchy_Frog/install.sh <<EOD 
$BRAT_USERNAME 
$BRAT_PASSWORD 
$BRAT_EMAIL
EOD

chown -R www-data:www-data /bratdata

exit 0
