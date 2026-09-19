#!/usr/bin/env bash
set -euo pipefail
DOMAIN="${1:?Usage: $0 domain email}"
EMAIL="${2:?Usage: $0 domain email}"
if ! command -v certbot >/dev/null; then sudo apt-get update && sudo apt-get install -y certbot python3-certbot-nginx; fi
sudo certbot --nginx -d "$DOMAIN" --email "$EMAIL" --agree-tos --no-eff-email --redirect
sudo systemctl reload nginx
