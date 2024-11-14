#!/bin/sh
set -eu
rsync --delete -avzP export/ root@lw:/var/www/html/pingpong2/
echo 'sudo chown -R www-data:www-data /var/www/html/pingpong2' | ssh lw
