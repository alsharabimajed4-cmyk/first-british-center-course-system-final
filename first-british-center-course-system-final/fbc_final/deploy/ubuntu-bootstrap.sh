#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update
sudo apt-get install -y nginx mysql-client curl unzip tesseract-ocr tesseract-ocr-eng tesseract-ocr-ara
# PHP package names may vary by Ubuntu release; install the distro-supported version.
sudo apt-get install -y php php-fpm php-mysql php-curl php-mbstring php-xml php-fileinfo
PHP_FPM=$(find /run/php -maxdepth 1 -name 'php*-fpm.sock' | head -1)
echo "PHP-FPM socket: ${PHP_FPM:-not found}"
echo "Next: copy this package, edit .env, run deploy/install.sh, configure deploy/nginx.conf.example, then use https-certbot.sh."
