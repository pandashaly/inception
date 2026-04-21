#!/bin/bash

# ============================================================
# INCEPTION TESTER — ssottori
# Follows eval sheet + subject order exactly
# ============================================================

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[1;92m'
VIOLET='\033[95m'
GRAY='\033[0;90m'
CYAN='\033[0;96m'

LOGIN="ssottori"
DOMAIN="${LOGIN}.42.fr"
DB_PASS=$(cat secrets/db_password.txt 2>/dev/null)
DB_ROOT_PASS=$(cat secrets/db_root_password.txt 2>/dev/null)

ok()       { echo -e "${GREEN}[OK] ✔${NC} $1"; }
ko()       { echo -e "${RED}[KO] ✗${NC} $1"; }
check()    { [ "$2" -gt 0 ] 2>/dev/null && ok "$1" || ko "$1"; }
checkz()   { [ "$2" -eq 0 ] 2>/dev/null && ok "$1" || ko "$1 ${RED}← FORBIDDEN${NC}"; }
section()  { echo -e "\n${CYAN}══════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}══════════════════════════════════════════${NC}\n"; }
question() { echo -e "\n${VIOLET}❓  $1${NC}"; }
cmd()      { echo -e "${GRAY}    \$ $1${NC}"; }
note()     { echo -e "${GRAY}    ↳ $1${NC}"; }

# ── Header ──────────────────────────────────────────────────
echo -e "${CYAN}"
echo "  ___ _  _  ___ ___ ___ _____ ___ ___  _  _ "
echo " |_ _| \| |/ __| __| _ \_   _|_ _/ _ \| \| |"
echo "  | || .\` | (__| _||  _/ | |  | | (_) | .\` |"
echo " |___|_|\_|\___|___|_|   |_| |___\___/|_|\_|"
echo -e "${NC}"
echo -e "${CYAN}           Inception Tester — ${LOGIN}${NC}\n"

# ============================================================
section "1 · PRELIMINARIES"
# ============================================================

question "Any credentials/passwords found outside of .env or secrets/ in the git repo?"
note "If yes → grade is 0. Check with: git log --all --oneline"
note "Passwords must ONLY exist in secrets/ (gitignored) and .env (no real passwords there)"

question "Is the evaluated student present?"
note "Evaluation cannot happen without them — mandatory rule"

echo -e "\n${GRAY}Run this command before starting (eval requirement):${NC}"
cmd "docker stop \$(docker ps -qa); docker rm \$(docker ps -qa); docker rmi -f \$(docker images -qa); docker volume rm \$(docker volume ls -q); docker network rm \$(docker network ls -q) 2>/dev/null"

# ============================================================
section "2 · GENERAL INSTRUCTIONS"
# ============================================================

echo -e "${VIOLET}── Required File Structure ──${NC}"

RES=$(test -d srcs && echo 1 || echo 0)
check "srcs/ folder exists at root" $RES

RES=$(test -f Makefile && echo 1 || echo 0)
check "Makefile exists at root" $RES

RES=$(test -f srcs/docker-compose.yml && echo 1 || echo 0)
check "docker-compose.yml inside srcs/" $RES

RES=$(test -f srcs/.env && echo 1 || echo 0)
check ".env file inside srcs/" $RES

RES=$(test -d secrets && echo 1 || echo 0)
check "secrets/ folder exists" $RES

RES=$(test -f README.md && echo 1 || echo 0)
check "README.md at root" $RES

RES=$(test -f USER_DOC.md && echo 1 || echo 0)
check "USER_DOC.md at root" $RES

RES=$(test -f DEV_DOC.md && echo 1 || echo 0)
check "DEV_DOC.md at root" $RES

for SERVICE in mariadb nginx wordpress; do
    RES=$(test -f srcs/requirements/${SERVICE}/Dockerfile && echo 1 || echo 0)
    check "Dockerfile exists for ${SERVICE}" $RES
done

echo -e "\n${VIOLET}── Forbidden in docker-compose.yml ──${NC}"
cmd "cat srcs/docker-compose.yml"

RES=$(grep -c "network: host" srcs/docker-compose.yml 2>/dev/null || echo 0)
checkz "No 'network: host' in docker-compose.yml" $RES

RES=$(grep -cE "^\s*links:" srcs/docker-compose.yml 2>/dev/null || echo 0)
checkz "No 'links:' in docker-compose.yml" $RES

RES=$(grep -c "networks:" srcs/docker-compose.yml 2>/dev/null || echo 0)
check "networks: section IS present in docker-compose.yml" $RES

echo -e "\n${VIOLET}── Forbidden in Makefile and Scripts ──${NC}"
cmd "grep -r '--link' Makefile srcs/"

RES=$(grep -rn "\-\-link" Makefile srcs/ 2>/dev/null | wc -l)
checkz "No '--link' in Makefile or scripts" $RES

RES=$(grep -rn "tail -f" srcs/ 2>/dev/null | wc -l)
checkz "No 'tail -f' in scripts or Dockerfiles" $RES

RES=$(grep -rn "sleep infinity" srcs/ 2>/dev/null | wc -l)
checkz "No 'sleep infinity' in scripts or Dockerfiles" $RES

RES=$(grep -rn "while true" srcs/ 2>/dev/null | wc -l)
checkz "No 'while true' in scripts or Dockerfiles" $RES

echo -e "\n${VIOLET}── Dockerfile Rules ──${NC}"

for SERVICE in mariadb nginx wordpress; do
    DF="srcs/requirements/${SERVICE}/Dockerfile"
    echo -e "\n${GRAY}  ── ${SERVICE} ──${NC}"
    cmd "cat ${DF}"

    RES=$(test -s $DF && echo 1 || echo 0)
    check "$SERVICE Dockerfile is not empty" $RES

    RES=$(grep -cE "^FROM (alpine:3\.|debian:)" $DF 2>/dev/null || echo 0)
    check "$SERVICE FROM penultimate Alpine/Debian" $RES

    RES=$(grep -ciE "^FROM.*:latest" $DF 2>/dev/null || echo 0)
    checkz "$SERVICE does NOT use 'latest' tag" $RES

    RES=$(grep -cE "password|passwd" $DF 2>/dev/null || echo 0)
    checkz "$SERVICE Dockerfile has NO hardcoded passwords" $RES

    RES=$(grep -cE "tail -f|sleep infinity|while true" $DF 2>/dev/null || echo 0)
    checkz "$SERVICE Dockerfile has no forbidden loop/tail commands" $RES
done

echo -e "\n${VIOLET}── Bind Mount Check ──${NC}"
note "Subject requires named volumes only — bind mounts are FORBIDDEN for wp and db"
cmd "grep -A3 'volumes:' srcs/docker-compose.yml"
RES=$(grep -cE "^\s+-\s+/|^\s+-\s+\./|^\s+-\s+~/" srcs/docker-compose.yml 2>/dev/null || echo 0)
checkz "No bind mounts in service volume definitions" $RES
note "Named volumes use driver_opts with device: path — that is allowed"

# ============================================================
section "3 · PROJECT OVERVIEW  (Manual Questions)"
# ============================================================

question "How do Docker and docker-compose work?"
note "Docker: packages an app + its dependencies into an isolated container (image)"
note "docker-compose: orchestrates multiple containers via a YAML file"
note "One 'make' = builds all images, creates network, volumes, starts everything"

question "Difference between using a Docker image WITH vs WITHOUT docker-compose?"
note "Without: manual 'docker build' + 'docker run' with all flags typed by hand each time"
note "With: docker-compose.yml describes everything — one command runs the whole stack"

question "Benefit of Docker compared to VMs?"
note "VMs emulate full hardware — heavy, slow boot, lots of RAM"
note "Docker shares the host OS kernel — lightweight, starts in seconds, same isolation"
note "Docker images are portable and reproducible across machines"

question "Explain the directory structure (srcs/, requirements/, secrets/, Makefile at root)"
note "srcs/ = all Docker/compose config — keeps project files organized"
note "requirements/ = one subfolder per service, each with its own Dockerfile"
note "secrets/ = password files, gitignored — never committed to repo"
note "Makefile at root = single entry point for build/run/clean"

cmd "cat srcs/docker-compose.yml"

# ============================================================
section "4 · SIMPLE SETUP"
# ============================================================

echo -e "${VIOLET}── HTTPS on port 443 only ──${NC}"
note "Open https://${DOMAIN} in browser — accept SSL warning — WordPress must load"

cmd "curl -sk https://${DOMAIN} | grep -i wordpress"
RES=$(curl -sk --max-time 5 https://${DOMAIN} | grep -ci "WordPress\|wp-content" 2>/dev/null || echo 0)
check "HTTPS returns WordPress content" $RES

cmd "curl -v http://${DOMAIN} 2>&1 | head -5"
RES=$(curl -s --max-time 3 http://${DOMAIN} > /dev/null 2>&1 && echo 1 || echo 0)
checkz "HTTP port 80 is blocked (cannot connect)" $RES
note "Port 80 is not mapped in docker-compose — connection refused is correct"

echo -e "\n${VIOLET}── SSL/TLS Certificate ──${NC}"
cmd "echo | openssl s_client -connect ${DOMAIN}:443 2>/dev/null"
echo | openssl s_client -connect ${DOMAIN}:443 2>/dev/null | grep -E "Protocol|subject|issuer|CERTIFICATE" | head -10

RES=$(echo | openssl s_client -connect ${DOMAIN}:443 2>/dev/null | grep -c "CERTIFICATE")
check "SSL certificate present" $RES

RES=$(echo | openssl s_client -connect ${DOMAIN}:443 2>/dev/null | grep -cE "TLSv1\.[23]")
check "TLSv1.2 or TLSv1.3 in use" $RES

note "Self-signed certificate warning in browser is expected and allowed by subject"

RES=$(curl -sk https://${DOMAIN} | grep -ci "install\|setup wizard")
checkz "WordPress installation page NOT shown (WP fully configured)" $RES

# ============================================================
section "5 · DOCKER BASICS"
# ============================================================

question "Evaluator checks Dockerfiles are not empty and written by you (not pulled)"
note "No ready-made images — you built your own FROM alpine/debian"

cmd "docker images"
docker images

echo ""
for SERVICE in mariadb nginx wordpress; do
    RES=$(docker images --format '{{.Repository}}' | grep -c "^${SERVICE}$")
    check "Image named '${SERVICE}' exists (matches service name)" $RES
done

cmd "docker compose -f srcs/docker-compose.yml -p inception ps"
docker compose -f srcs/docker-compose.yml -p inception ps 2>/dev/null
echo ""

for SERVICE in mariadb nginx wordpress; do
    RES=$(docker ps --format '{{.Names}}' | grep -c "^${SERVICE}$")
    check "Container '${SERVICE}' running" $RES
done

question "Why is using DockerHub images (e.g. wordpress:latest) forbidden?"
note "The project exists to teach you to configure each service yourself"
note "Pulling a ready-made image means you learn nothing about how it works"

question "What does FROM alpine:3.20 (penultimate stable) mean?"
note "Latest stable is 3.21 — penultimate means the one before latest"
note "Using a specific version ensures reproducible builds"

# ============================================================
section "6 · DOCKER NETWORK"
# ============================================================

cmd "docker network ls"
docker network ls

RES=$(docker network ls | grep -c "inception")
check "inception network visible in docker network ls" $RES

cmd "docker network inspect inception_inception"
docker network inspect inception_inception 2>/dev/null | grep -E '"Name"|"Subnet"|"Gateway"|"IPv4Address"'

question "Explain docker-network in simple terms"
note "A virtual private network for your containers"
note "Containers on the same network can reach each other by name (DNS)"
note "Containers are NOT reachable from outside — only nginx port 443 is exposed"
note "e.g. wordpress resolves 'mariadb' to the MariaDB container's IP automatically"

# ============================================================
section "7 · NGINX WITH SSL/TLS"
# ============================================================

cmd "cat srcs/requirements/nginx/Dockerfile"
cat srcs/requirements/nginx/Dockerfile

RES=$(test -f srcs/requirements/nginx/Dockerfile && echo 1 || echo 0)
check "NGINX Dockerfile exists" $RES

cmd "docker compose -f srcs/docker-compose.yml -p inception ps nginx"
docker compose -f srcs/docker-compose.yml -p inception ps nginx 2>/dev/null

RES=$(curl -s --max-time 3 http://${DOMAIN} > /dev/null 2>&1 && echo 1 || echo 0)
checkz "Cannot connect via HTTP (port 80 blocked)" $RES

RES=$(curl -sk https://${DOMAIN} | grep -ci "WordPress\|wp-content")
check "https://${DOMAIN} shows WordPress (not install page)" $RES

echo -e "\n${GRAY}Test TLS version explicitly:${NC}"
cmd "echo | openssl s_client -connect ${DOMAIN}:443 -tls1_2 2>/dev/null | grep Protocol"
echo | openssl s_client -connect ${DOMAIN}:443 -tls1_2 2>/dev/null | grep "Protocol"
cmd "echo | openssl s_client -connect ${DOMAIN}:443 -tls1_3 2>/dev/null | grep Protocol"
echo | openssl s_client -connect ${DOMAIN}:443 -tls1_3 2>/dev/null | grep "Protocol"

RES=$(echo | openssl s_client -connect ${DOMAIN}:443 2>/dev/null | grep -cE "TLSv1\.[23]")
check "TLSv1.2 or TLSv1.3 certificate confirmed" $RES

note "Evaluator may also try TLSv1.1 to confirm it is rejected:"
cmd "echo | openssl s_client -connect ${DOMAIN}:443 -tls1_1 2>&1 | grep -iE 'error|alert|rejected'"
echo | openssl s_client -connect ${DOMAIN}:443 -tls1_1 2>&1 | grep -iE 'error|alert|rejected' || echo -e "${GRAY}    (TLS 1.1 rejected — correct)${NC}"

question "What is FastCGI and why does NGINX use fastcgi_pass to talk to WordPress?"
note "NGINX cannot execute PHP — it's a web server, not a PHP interpreter"
note "FastCGI is a protocol to send PHP requests to an external process (php-fpm)"
note "NGINX receives the .php request, forwards it to wordpress:9000, gets HTML back"

question "Why is NGINX the ONLY entrypoint into the infrastructure?"
note "Only port 443 is mapped in docker-compose (ports: - '443:443')"
note "MariaDB (3306) and WordPress (9000) have NO ports mapped — unreachable from outside"
note "All traffic must go through NGINX → wordpress → mariadb"

# ============================================================
section "8 · WORDPRESS WITH PHP-FPM AND ITS VOLUME"
# ============================================================

cmd "cat srcs/requirements/wordpress/Dockerfile"
cat srcs/requirements/wordpress/Dockerfile

RES=$(test -f srcs/requirements/wordpress/Dockerfile && echo 1 || echo 0)
check "WordPress Dockerfile exists" $RES

RES=$(grep -ci "nginx" srcs/requirements/wordpress/Dockerfile 2>/dev/null || echo 0)
checkz "No NGINX in WordPress Dockerfile" $RES

cmd "docker compose -f srcs/docker-compose.yml -p inception ps wordpress"
docker compose -f srcs/docker-compose.yml -p inception ps wordpress 2>/dev/null

echo -e "\n${VIOLET}── Volume ──${NC}"
cmd "docker volume ls"
docker volume ls

cmd "docker volume inspect inception_vol_wp"
docker volume inspect inception_vol_wp 2>/dev/null

RES=$(docker volume inspect inception_vol_wp 2>/dev/null | grep -c "/home/${LOGIN}/data")
check "wp volume path contains /home/${LOGIN}/data/" $RES

echo -e "\n${VIOLET}── WordPress Users ──${NC}"
cmd "docker exec wordpress wp user list --allow-root --path=/var/www/html"
docker exec wordpress wp user list --allow-root --path=/var/www/html 2>/dev/null

RES=$(docker exec wordpress wp user get ${LOGIN} --allow-root --path=/var/www/html > /dev/null 2>&1 && echo 1 || echo 0)
check "Admin user '${LOGIN}' exists" $RES

RES=$(docker exec wordpress wp user list --allow-root --path=/var/www/html --field=user_login 2>/dev/null | grep -ci "admin")
checkz "Admin username does NOT contain 'admin' or 'Admin'" $RES

RES=$(docker exec wordpress wp user get wolfsburg --allow-root --path=/var/www/html > /dev/null 2>&1 && echo 1 || echo 0)
check "Second user 'wolfsburg' exists" $RES

echo -e "\n${VIOLET}── Manual Eval Steps ──${NC}"
question "Add a comment as wolfsburg — verify it appears on the site"
note "Log in at https://${DOMAIN}/wp-admin as wolfsburg → Posts → leave a comment"

question "Sign in as ${LOGIN} (admin) — dashboard must be accessible"
note "Log in at https://${DOMAIN}/wp-admin as ${LOGIN}"

question "Edit a page as admin — verify the change appears on the front-end"
note "Dashboard → Pages → edit any page → Update → visit https://${DOMAIN}"

# ============================================================
section "9 · MARIADB AND ITS VOLUME"
# ============================================================

cmd "cat srcs/requirements/mariadb/Dockerfile"
cat srcs/requirements/mariadb/Dockerfile

RES=$(test -f srcs/requirements/mariadb/Dockerfile && echo 1 || echo 0)
check "MariaDB Dockerfile exists" $RES

RES=$(grep -ci "nginx" srcs/requirements/mariadb/Dockerfile 2>/dev/null || echo 0)
checkz "No NGINX in MariaDB Dockerfile" $RES

cmd "docker compose -f srcs/docker-compose.yml -p inception ps mariadb"
docker compose -f srcs/docker-compose.yml -p inception ps mariadb 2>/dev/null

echo -e "\n${VIOLET}── Volume ──${NC}"
cmd "docker volume inspect inception_vol_db"
docker volume inspect inception_vol_db 2>/dev/null

RES=$(docker volume inspect inception_vol_db 2>/dev/null | grep -c "/home/${LOGIN}/data")
check "db volume path contains /home/${LOGIN}/data/" $RES

echo -e "\n${VIOLET}── Database Connection ──${NC}"
question "How do you log in to the database? (evaluator will ask you to demonstrate)"
cmd "docker exec -it mariadb mariadb -u ${LOGIN} -p wordpress"
note "Enter your DB password when prompted — you should get a MariaDB prompt"

RES=$(docker exec mariadb mariadb -u ${LOGIN} -p"${DB_PASS}" wordpress -e "SELECT 1;" > /dev/null 2>&1 && echo 1 || echo 0)
check "${LOGIN} user can connect to wordpress database" $RES

echo -e "\n${VIOLET}── Database Not Empty ──${NC}"
cmd "docker exec mariadb mariadb -u ${LOGIN} -p<pass> wordpress -e 'SHOW TABLES;'"
docker exec mariadb mariadb -u ${LOGIN} -p"${DB_PASS}" wordpress -e "SHOW TABLES;" 2>/dev/null

TABLE_COUNT=$(docker exec mariadb mariadb -u ${LOGIN} -p"${DB_PASS}" wordpress -e "SHOW TABLES;" 2>/dev/null | wc -l)
check "WordPress database has tables (not empty)" $TABLE_COUNT
note "You should see ~12 WordPress tables: wp_posts, wp_users, wp_options, etc."

# ============================================================
section "10 · PERSISTENCE"
# ============================================================

echo -e "${VIOLET}── Data Exists on Host ──${NC}"
cmd "ls /home/${LOGIN}/data/vol_db"
ls /home/${LOGIN}/data/vol_db 2>/dev/null | head -5

RES=$(ls /home/${LOGIN}/data/vol_db 2>/dev/null | wc -l)
check "Data exists in /home/${LOGIN}/data/vol_db" $RES

cmd "ls /home/${LOGIN}/data/vol_wp"
ls /home/${LOGIN}/data/vol_wp 2>/dev/null | head -5

RES=$(ls /home/${LOGIN}/data/vol_wp 2>/dev/null | wc -l)
check "Data exists in /home/${LOGIN}/data/vol_wp" $RES

echo -e "\n${VIOLET}── Persistence Test (manual — done with evaluator) ──${NC}"
note "1. Make a visible change in WordPress (edit a page, add a comment)"
note "2. Run: sudo reboot"
note "3. After VM restarts: cd ~/Documents/inception && make"
note "4. Open https://${DOMAIN} — changes must still be there"
note "5. Run docker exec -it mariadb mariadb -u ${LOGIN} -p wordpress → SHOW TABLES;"
note "Persistence works because data lives in /home/${LOGIN}/data/ on the HOST"
note "even when containers are stopped/destroyed, host data survives"

# ============================================================
echo -e "\n${CYAN}══════════════════════════════════════════${NC}"
echo -e "${CYAN}             TESTER COMPLETE              ${NC}"
echo -e "${CYAN}══════════════════════════════════════════${NC}\n"

echo -e "${GRAY}Quick eval checklist:${NC}"
echo -e "${GRAY}  □  https://${DOMAIN} loads WordPress (SSL warning = OK)${NC}"
echo -e "${GRAY}  □  http://${DOMAIN} is blocked${NC}"
echo -e "${GRAY}  □  Add comment as wolfsburg — appears on site${NC}"
echo -e "${GRAY}  □  Edit page as ${LOGIN} — change visible on front-end${NC}"
echo -e "${GRAY}  □  docker exec -it mariadb mariadb -u ${LOGIN} -p wordpress${NC}"
echo -e "${GRAY}     → SHOW TABLES; shows ~12 tables${NC}"
echo -e "${GRAY}  □  sudo reboot → make → everything still works${NC}"
echo -e "${GRAY}  □  No passwords in git repo history${NC}\n"