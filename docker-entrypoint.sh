#!/bin/sh
ln -s /data/images /var/www/html/images
ln -s /data/LocalSettings.php /var/www/html/LocalSettings.php
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf