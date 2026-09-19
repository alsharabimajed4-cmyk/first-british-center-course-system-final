#!/usr/bin/env bash
set -euo pipefail
APP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$APP_DIR"

echo "== The First British Center Course System installer =="
if [[ ! -f .env ]]; then cp .env.example .env; echo "Created .env from .env.example. Edit DB_* and ADMIN_* values, then run this script again."; exit 2; fi
command -v php >/dev/null || { echo "PHP is required."; exit 1; }
php -v | head -1
php -m | grep -qi pdo_mysql || { echo "PHP PDO MySQL extension is required."; exit 1; }
php -m | grep -qi curl || { echo "PHP cURL extension is required for Google OAuth."; exit 1; }
php -r 'require "config/bootstrap.php"; db()->query("SELECT 1"); echo "Database connection OK\n";' 
php -r 'require "config/bootstrap.php"; $sql=file_get_contents("database/schema.sql"); foreach(array_filter(array_map("trim",preg_split("/;\\s*(?:\\r?\\n|$)/",$sql))) as $q){ if($q!=="") db()->exec($q); } echo "Schema imported\n";'
php install/seed.php
chmod 700 storage storage/private storage/uploads storage/ocr || true
chmod 600 .env || true
find public -type f -name '*.php' -exec chmod 640 {} \; || true
find config database install deploy docs -type f -exec chmod 640 {} \; || true
echo "Install complete. Configure your Nginx/Apache document root to: $APP_DIR/public"
