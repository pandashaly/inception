#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"
OK="${GREEN}OK${RESET}"
FAIL="${RED}FAIL${RESET}"

echo "=== Full Integration Tests ==="

# --- STRUCTURE ---
echo -n "[1]  srcs/ folder exists... "
test -d srcs && echo -e "$OK" || echo -e "$FAIL"

echo -n "[2]  Makefile at root... "
test -f Makefile && echo -e "$OK" || echo -e "$FAIL"

echo -n "[3]  docker-compose.yml in srcs/... "
test -f srcs/docker-compose.yml && echo -e "$OK" || echo -e "$FAIL"

# --- CONTAINERS ---
echo -n "[4]  all 3 containers running... "
COUNT=$(docker ps --format '{{.Names}}' | grep -cE "^(nginx|wordpress|mariadb)$")
[ "$COUNT" -eq 3 ] && echo -e "$OK" || echo -e "$FAIL (only $COUNT running)"

# --- NETWORK ---
echo -n "[5]  inception network exists... "
docker network ls | grep -q "inception" && echo -e "$OK" || echo -e "$FAIL"

echo -n "[6]  all containers on same network... "
NW=$(docker inspect mariadb wordpress nginx --format '{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}' 2>/dev/null | sort -u | wc -l)
[ "$NW" -eq 1 ] && echo -e "$OK" || echo -e "$FAIL (containers on different networks)"

# --- VOLUMES ---
echo -n "[7]  vol_db exists with correct path... "
docker volume inspect inception_vol_db 2>/dev/null | grep -q "/home/ssottori/data" && echo -e "$OK" || echo -e "$FAIL"

echo -n "[8]  vol_wp exists with correct path... "
docker volume inspect inception_vol_wp 2>/dev/null | grep -q "/home/ssottori/data" && echo -e "$OK" || echo -e "$FAIL"

# --- NGINX / TLS ---
echo -n "[9]  HTTPS works (port 443)... "
curl -sk https://ssottori.42.fr | grep -q "WordPress\|wp-" && echo -e "$OK" || echo -e "$FAIL"

echo -n "[10] HTTP port 80 is blocked... "
curl -s --max-time 3 http://ssottori.42.fr > /dev/null 2>&1 && echo -e "${RED}FAIL (port 80 open!)${RESET}" || echo -e "$OK"

echo -n "[11] TLSv1.2 or TLSv1.3 only... "
echo | openssl s_client -connect ssottori.42.fr:443 2>/dev/null | grep -qE "TLSv1\.[23]" && echo -e "$OK" || echo -e "$FAIL"

# --- WORDPRESS ---
echo -n "[12] WordPress installed (no setup page)... "
curl -sk https://ssottori.42.fr | grep -q "WordPress\|wp-content" && echo -e "$OK" || echo -e "$FAIL"

echo -n "[13] wp-config.php exists... "
docker exec wordpress test -f /var/www/html/wp-config.php && echo -e "$OK" || echo -e "$FAIL"

echo -n "[14] admin user ssottori exists... "
docker exec wordpress wp user get ssottori --allow-root --path=/var/www/html > /dev/null 2>&1 && echo -e "$OK" || echo -e "$FAIL"

echo -n "[15] admin username has no 'admin'... "
docker exec wordpress wp user list --allow-root --path=/var/www/html --field=user_login 2>/dev/null | grep -qi "admin" && echo -e "${RED}FAIL${RESET}" || echo -e "$OK"

echo -n "[16] second user wolfsburg exists... "
docker exec wordpress wp user get wolfsburg --allow-root --path=/var/www/html > /dev/null 2>&1 && echo -e "$OK" || echo -e "$FAIL"

# --- MARIADB ---
echo -n "[17] wordpress DB not empty (has tables)... "
PASS=$(cat secrets/db_password.txt)
COUNT=$(docker exec mariadb mariadb -u ssottori -p"$PASS" wordpress -e "SHOW TABLES;" 2>/dev/null | wc -l)
[ "$COUNT" -gt 5 ] && echo -e "$OK" || echo -e "$FAIL (only $COUNT tables)"

echo -n "[18] containers restart policy set... "
POLICIES=$(docker inspect nginx wordpress mariadb --format '{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null | sort -u)
echo "$POLICIES" | grep -q "unless-stopped" && echo -e "$OK" || echo -e "$FAIL"

# --- FORBIDDEN CHECKS ---
echo -n "[19] no 'network: host' in compose file... "
grep -q "network: host" srcs/docker-compose.yml && echo -e "${RED}FAIL${RESET}" || echo -e "$OK"

echo -n "[20] no 'links:' in compose file... "
grep -q "links:" srcs/docker-compose.yml && echo -e "${RED}FAIL${RESET}" || echo -e "$OK"

echo "=============================="
echo ""
echo "MANUAL eval checks (do these yourself):"
echo "  - Open https://ssottori.42.fr — WordPress site loads, no install page"
echo "  - Try http://ssottori.42.fr  — must fail/refuse"
echo "  - Log in as ssottori at /wp-admin — dashboard accessible"
echo "  - Add a comment as wolfsburg"
echo "  - Edit a page as ssottori — verify change appears on site"
echo "  - Run: docker exec -it mariadb mariadb -u ssottori -p<pass> wordpress"
echo "    then: SHOW TABLES; — must show ~12 WordPress tables"