#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"
OK="${GREEN}OK${RESET}"
FAIL="${RED}FAIL${RESET}"

echo "=== WordPress Tests ==="

# Eval: "ensure there is no NGINX in the Dockerfile" — one service per container
echo -n "[1] Container running... "
docker ps --format '{{.Names}}' | grep -q "^wordpress$" && echo -e "$OK" || echo -e "$FAIL"

# Eval: "ensure there is no NGINX in the Dockerfile"
echo -n "[2] nginx NOT in wordpress container... "
docker exec wordpress which nginx > /dev/null 2>&1 && echo -e "${RED}FAIL${RESET}" || echo -e "$OK"

# Subject: wordpress must be installed and configured — no installation page
# wp-config.php is created by wp-cli during setup
echo -n "[3] wp-config.php exists... "
docker exec wordpress test -f /var/www/html/wp-config.php && echo -e "$OK" || echo -e "$FAIL"

# php-fpm must listen on 9000 so NGINX can reach it from another container
# Port 9000 in hex is 2328 — /proc/net/tcp is reliable in Alpine
echo -n "[4] php-fpm listening on port 9000... "
{ docker exec wordpress cat /proc/net/tcp 2>/dev/null
  docker exec wordpress cat /proc/net/tcp6 2>/dev/null; } | grep -q ":2328" && echo -e "$OK" || echo -e "$FAIL"

echo -n "[5] admin user exists (ssottori)... "
docker exec wordpress wp user get ssottori --allow-root --path=/var/www/html > /dev/null 2>&1 && echo -e "$OK" || echo -e "$FAIL"

echo -n "[6] admin username does not contain 'admin'... "
docker exec wordpress wp user list --allow-root --path=/var/www/html --field=user_login 2>/dev/null | grep -qi "admin" && echo -e "${RED}FAIL (admin in username!)${RESET}" || echo -e "$OK"

echo -n "[7] regular user exists (wolfsburg)... "
docker exec wordpress wp user get wolfsburg --allow-root --path=/var/www/html > /dev/null 2>&1 && echo -e "$OK" || echo -e "$FAIL"
# Volume must persist WordPress files
echo -n "[8] wordpress volume mounted correctly... "
docker exec wordpress test -d /var/www/html/wp-content && echo -e "$OK" || echo -e "$FAIL"

# Eval: "docker compose ps" check
echo -n "[9] docker compose ps shows wordpress running... "
docker compose -f srcs/docker-compose.yml -p inception ps --services --filter "status=running" 2>/dev/null | grep -q "wordpress" && echo -e "$OK" || echo -e "$FAIL"

echo "====================="
# MANUAL CHECK for eval:
# - Open srcs/requirements/wordpress/Dockerfile — confirm no nginx, no passwords
# - FROM must be alpine:3.20 (not latest)
# - Evaluator will ask: "how does WordPress connect to MariaDB?" 
#   Answer: wp-config.php has DB_HOST=mariadb (Docker DNS resolves container names)
# - Evaluator will ask: "why php-fpm and not just PHP?"
#   Answer: php-fpm is a process manager for PHP — it keeps PHP workers alive and
#   handles concurrent requests efficiently. NGINX hands off .php requests to it
#   via FastCGI protocol on port 9000, rather than spawning a new PHP process each time