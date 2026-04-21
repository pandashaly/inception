#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
#  INCEPTION TESTER  ·  ssottori  ·  follows eval sheet order
# ─────────────────────────────────────────────────────────────────────────────

NC='\033[0m';      RED='\033[0;31m';    GREEN='\033[1;92m'
VIOLET='\033[95m'; GRAY='\033[0;90m';   CYAN='\033[0;96m'
YELLOW='\033[1;33m'; BOLD='\033[1m';    DIM='\033[2m'

LOGIN="ssottori"
DOMAIN="${LOGIN}.42.fr"
DB_PASS=$(cat secrets/db_password.txt 2>/dev/null)
DB_ROOT_PASS=$(cat secrets/db_root_password.txt 2>/dev/null)

PASS=0; FAIL=0

# ── Helpers ──────────────────────────────────────────────────────────────────

ok()     { echo -e "  ${GREEN}[ ✔ OK ]${NC}  $1"; PASS=$((PASS+1)); }
ko()     { echo -e "  ${RED}[ ✘ KO ]${NC}  $1"; FAIL=$((FAIL+1)); }
check()  { if [ "$2" -gt 0 ] 2>/dev/null; then ok "$1"; else ko "$1"; fi; }
checkz() { if [ "$2" -eq 0 ] 2>/dev/null; then ok "$1"; else ko "$1  ${RED}← FORBIDDEN${NC}"; fi; }
cmd()    { echo -e "\n  ${GRAY}  \$ $1${NC}"; }
note()   { echo -e "  ${GRAY}  ↳  $1${NC}"; }

question() {
    echo -e "\n  ${VIOLET}╭─ ❓  $1${NC}"
    shift
    for line in "$@"; do
        echo -e "  ${VIOLET}│${NC}  ${GRAY}$line${NC}"
    done
    echo ""
}

sub() {
    echo -e "\n  ${BOLD}${CYAN}▸  $1${NC}"
    echo ""
}

summary() {
    echo ""
    if [ "$FAIL" -eq 0 ]; then
        echo -e "  ${GREEN}✔ ${PASS} passed${NC}   ${DIM}all good!${NC}"
    else
        echo -e "  ${GREEN}✔ ${PASS} passed${NC}   ${RED}✘ ${FAIL} failed${NC}   ← fix before eval"
    fi
    echo ""
    PASS=0
    FAIL=0
}

section_banner() {
    echo -e "\n${BOLD}${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    printf "${BOLD}${CYAN}║${NC}  %-47s${BOLD}${CYAN}║${NC}\n" "$1"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════╝${NC}"
}

print_header() {
    clear
    echo -e "${CYAN}"
    echo "    ██╗███╗   ██╗ ██████╗███████╗██████╗ ████████╗██╗ ██████╗ ███╗   ██╗"
    echo "    ██║████╗  ██║██╔════╝██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║"
    echo "    ██║██╔██╗ ██║██║     █████╗  ██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║"
    echo "    ██║██║╚██╗██║██║     ██╔══╝  ██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║"
    echo "    ██║██║ ╚████║╚██████╗███████╗██║        ██║   ██║╚██████╔╝██║ ╚████║"
    echo "    ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝"
    echo -e "${NC}"
    echo -e "  ${DIM}${CYAN}tester by pandashaly  ·  project by ${LOGIN}${NC}\n"
}

show_menu() {
    print_header
    echo -e "  ${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "  ${CYAN}║${NC}  ${YELLOW}0${NC}  ·  Run All Sections                          ${CYAN}║${NC}"
    echo -e "  ${CYAN}╠══════════════════════════════════════════════════╣${NC}"
    echo -e "  ${CYAN}║${NC}  ${GREEN}1${NC}  ·  Preliminaries                              ${CYAN}║${NC}"
    echo -e "  ${CYAN}║${NC}  ${GREEN}2${NC}  ·  General Instructions                       ${CYAN}║${NC}"
    echo -e "  ${CYAN}║${NC}  ${GREEN}3${NC}  ·  Project Overview  (Questions)              ${CYAN}║${NC}"
    echo -e "  ${CYAN}║${NC}  ${GREEN}4${NC}  ·  Simple Setup                               ${CYAN}║${NC}"
    echo -e "  ${CYAN}║${NC}  ${GREEN}5${NC}  ·  Docker Basics                              ${CYAN}║${NC}"
    echo -e "  ${CYAN}║${NC}  ${GREEN}6${NC}  ·  Docker Network                             ${CYAN}║${NC}"
    echo -e "  ${CYAN}║${NC}  ${GREEN}7${NC}  ·  NGINX with SSL/TLS                         ${CYAN}║${NC}"
    echo -e "  ${CYAN}║${NC}  ${GREEN}8${NC}  ·  WordPress + php-fpm + Volume               ${CYAN}║${NC}"
    echo -e "  ${CYAN}║${NC}  ${GREEN}9${NC}  ·  MariaDB + Volume                           ${CYAN}║${NC}"
    echo -e "  ${CYAN}║${NC}  ${GREEN}10${NC} ·  Persistence                                ${CYAN}║${NC}"
    echo -e "  ${CYAN}╠══════════════════════════════════════════════════╣${NC}"
    echo -e "  ${CYAN}║${NC}  ${RED}q${NC}  ·  Quit                                       ${CYAN}║${NC}"
    echo -e "  ${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo -ne "\n  ${BOLD}Choose:${NC} "
}

# ── Sections ─────────────────────────────────────────────────────────────────

section_1() {
    section_banner "1 · PRELIMINARIES"

    question "Any credentials/passwords in the git repo outside of .env or secrets/?" \
        "Run: git log --all --oneline  and  git status" \
        "Secrets must ONLY live in secrets/ (gitignored) — if found in repo → grade is 0"

    question "Is the evaluated student present?" \
        "Defense requires presence — if not, evaluation stops"

    sub "Eval cleanup command (run this before starting evaluation)"
    cmd "docker stop \$(docker ps -qa); docker rm \$(docker ps -qa); \\"
    echo -e "  ${GRAY}       docker rmi -f \$(docker images -qa); docker volume rm \$(docker volume ls -q); \\"
    echo -e "       docker network rm \$(docker network ls -q) 2>/dev/null${NC}"
    note "This clears everything — then run 'make' to build fresh"

    summary
}

section_2() {
    section_banner "2 · GENERAL INSTRUCTIONS"

    sub "Required file structure"
    check "srcs/ folder exists at root"                                  $(test -d srcs && echo 1 || echo 0)
    check "Makefile exists at root"                                      $(test -f Makefile && echo 1 || echo 0)
    check "docker-compose.yml inside srcs/"                              $(test -f srcs/docker-compose.yml && echo 1 || echo 0)
    check ".env file inside srcs/"                                       $(test -f srcs/.env && echo 1 || echo 0)
    check "secrets/ folder exists"                                       $(test -d secrets && echo 1 || echo 0)
    check "README.md at root"                                            $(test -f README.md && echo 1 || echo 0)
    check "USER_DOC.md at root"                                          $(test -f USER_DOC.md && echo 1 || echo 0)
    check "DEV_DOC.md at root"                                           $(test -f DEV_DOC.md && echo 1 || echo 0)
    for S in mariadb nginx wordpress; do
        check "Dockerfile exists for $S"                                 $(test -f srcs/requirements/$S/Dockerfile && echo 1 || echo 0)
    done

    sub "docker-compose.yml — forbidden checks"
    cmd "cat srcs/docker-compose.yml"
    checkz "No 'network: host' in docker-compose.yml"                   $(grep -c "network: host" srcs/docker-compose.yml 2>/dev/null || echo 0)
    checkz "No 'links:' in docker-compose.yml"                          $(grep -cE "^\s*links:" srcs/docker-compose.yml 2>/dev/null || echo 0)
    check  "networks: section IS present in docker-compose.yml"         $(grep -c "networks:" srcs/docker-compose.yml 2>/dev/null || echo 0)

    sub "Makefile & scripts — forbidden checks"
    cmd "grep -rn '\-\-link' Makefile srcs/"
    checkz "No '--link' anywhere in Makefile or scripts"                 $(grep -rn "\-\-link" Makefile srcs/ 2>/dev/null | wc -l)
    checkz "No 'tail -f' in scripts or Dockerfiles"                      $(grep -rn "tail -f" srcs/ 2>/dev/null | wc -l)
    checkz "No 'sleep infinity' in scripts or Dockerfiles"               $(grep -rn "sleep infinity" srcs/ 2>/dev/null | wc -l)
    checkz "No 'while true' in scripts or Dockerfiles"                   $(grep -rn "while true" srcs/ 2>/dev/null | wc -l)

    sub "Dockerfiles — per service"
    for S in mariadb nginx wordpress; do
        DF="srcs/requirements/${S}/Dockerfile"
        echo -e "  ${GRAY}── ${S} ──${NC}"
        cmd "cat $DF"
        check  "$S · Dockerfile not empty"                               $(test -s $DF && echo 1 || echo 0)
        check  "$S · FROM penultimate Alpine/Debian (not latest)"        $(grep -cE "^FROM (alpine:3\.|debian:)" $DF 2>/dev/null || echo 0)
        checkz "$S · No 'latest' tag"                                    $(grep -ciE "^FROM.*:latest" $DF 2>/dev/null || echo 0)
        checkz "$S · No hardcoded passwords in Dockerfile"               $(grep -ciE "password\s*=" $DF 2>/dev/null || echo 0)
        checkz "$S · No forbidden loop/tail commands in Dockerfile"      $(grep -cE "tail -f|sleep infinity|while true" $DF 2>/dev/null || echo 0)
        echo ""
    done

    sub "Bind mount check"
    note "Subject: bind mounts are FORBIDDEN — must use Docker named volumes"
    cmd "grep -A3 'volumes:' srcs/docker-compose.yml"
    checkz "No bind mounts in service volume definitions"                $(grep -cE "^\s+-\s+(/|\.\/|~\/)" srcs/docker-compose.yml 2>/dev/null || echo 0)
    note "driver_opts with device: is allowed — that backs a named volume to a host path"

    summary
}

section_3() {
    section_banner "3 · PROJECT OVERVIEW  (Manual Questions)"

    question "How do Docker and docker-compose work?" \
        "Docker: packages an app + dependencies into an isolated image/container" \
        "docker-compose: orchestrates multiple containers via a YAML file" \
        "One 'make' = builds all images, creates network + volumes, starts everything"

    question "Difference between using an image WITH vs WITHOUT docker-compose?" \
        "Without: manual 'docker build' + 'docker run' with ALL flags typed by hand each time" \
        "With: docker-compose.yml describes the full stack — one command runs it all"

    question "Benefit of Docker compared to VMs?" \
        "VMs emulate full hardware — heavy, slow to boot, high RAM usage" \
        "Docker shares the host OS kernel — lightweight, starts in seconds, same isolation" \
        "Docker images are portable and reproducible across machines"

    question "Explain the directory structure required by the subject" \
        "srcs/           → all Docker/compose config files" \
        "requirements/   → one subfolder per service, each with its own Dockerfile" \
        "secrets/        → password files, gitignored, never committed" \
        "Makefile        → single entry point at root: make / make fclean / make re"

    question "Secrets vs Environment Variables — what is the difference?" \
        "Env vars (.env): non-sensitive config like domain, usernames, DB name" \
        "Secrets (files in secrets/): actual passwords — mounted at /run/secrets/ inside containers" \
        "Passwords are never passed as env vars — they'd be visible in docker inspect"

    question "Docker Volumes vs Bind Mounts — why named volumes here?" \
        "Bind mounts: link a host path directly — FORBIDDEN by the subject for wp+db" \
        "Named volumes: managed by Docker — we use driver_opts to back them to a host path" \
        "This satisfies both: 'named volume' AND 'data in /home/ssottori/data/'"

    question "Docker Network vs Host Network — why not host?" \
        "host network: container shares host's network stack — removes isolation, FORBIDDEN" \
        "Custom bridge network: containers get private IPs, talk by name (DNS), isolated from outside"

    cmd "cat srcs/docker-compose.yml"

    summary
}

section_4() {
    section_banner "4 · SIMPLE SETUP"

    sub "HTTPS on port 443 — only entry point"
    note "Open https://${DOMAIN} in browser — accept SSL warning — WordPress must load"
    cmd "curl -sk https://${DOMAIN} | grep -i 'wordpress'"
    RES=$(curl -sk --max-time 5 https://${DOMAIN} 2>/dev/null | grep -ci "WordPress\|wp-content" || echo 0)
    check "HTTPS returns WordPress content" $RES

    sub "HTTP port 80 must be blocked"
    cmd "curl -v http://${DOMAIN} 2>&1 | head -5"
    RES=$(curl -s --max-time 3 http://${DOMAIN} > /dev/null 2>&1 && echo 1 || echo 0)
    checkz "HTTP port 80 is blocked (connection refused)" $RES
    note "Port 80 is simply not mapped in docker-compose — connection refused is correct"

    sub "SSL/TLS certificate"
    cmd "echo | openssl s_client -connect ${DOMAIN}:443 2>/dev/null"
    echo | openssl s_client -connect ${DOMAIN}:443 2>/dev/null | grep -E "Protocol|subject|issuer|CERTIFICATE" | head -8
    RES=$(echo | openssl s_client -connect ${DOMAIN}:443 2>/dev/null | grep -c "CERTIFICATE")
    check "SSL certificate present" $RES
    RES=$(echo | openssl s_client -connect ${DOMAIN}:443 2>/dev/null | grep -cE "TLSv1\.[23]")
    check "TLSv1.2 or TLSv1.3 in use" $RES
    note "Self-signed certificate warning in browser is expected and allowed by subject"

    sub "WordPress fully configured"
    RES=$(curl -sk https://${DOMAIN} 2>/dev/null | grep -ci "install\|setup wizard")
    checkz "WordPress installation page is NOT shown" $RES
    check  "WordPress site content is visible" $(curl -sk --max-time 5 https://${DOMAIN} 2>/dev/null | grep -ci "WordPress\|wp-" || echo 0)

    summary
}

section_5() {
    section_banner "5 · DOCKER BASICS"

    sub "Each image must have the same name as its service"
    cmd "docker images"
    docker images
    echo ""
    for S in mariadb nginx wordpress; do
        check "Image named '${S}' exists (matches service name)" $(docker images --format '{{.Repository}}' | grep -c "^${S}$")
    done

    sub "All containers running"
    cmd "docker compose -f srcs/docker-compose.yml -p inception ps"
    docker compose -f srcs/docker-compose.yml -p inception ps 2>/dev/null
    echo ""
    for S in mariadb nginx wordpress; do
        check "Container '${S}' is running" $(docker ps --format '{{.Names}}' | grep -c "^${S}$")
    done

    question "Why is using DockerHub ready-made images forbidden?" \
        "The project teaches you to configure each service yourself from scratch" \
        "A ready-made wordpress image hides all the configuration — you learn nothing" \
        "Alpine/Debian base images ARE allowed — everything else must be built by you"

    question "What does FROM alpine:3.20 (penultimate stable) mean?" \
        "Latest stable is 3.21 — penultimate = the one before latest" \
        "Using a specific version ensures reproducible builds across machines" \
        "The 'latest' tag is explicitly forbidden by the subject"

    question "What is php-fpm and why is it separate from NGINX?" \
        "php-fpm = FastCGI Process Manager — keeps PHP workers alive to serve requests" \
        "NGINX cannot execute PHP itself — it's a web server only" \
        "NGINX hands .php requests to php-fpm via FastCGI protocol on port 9000" \
        "Separating them = each container has one responsibility (single concern)"

    summary
}

section_6() {
    section_banner "6 · DOCKER NETWORK"

    sub "Inception network visible"
    cmd "docker network ls"
    docker network ls
    echo ""
    check "inception network visible in 'docker network ls'" $(docker network ls | grep -c "inception")

    sub "Inspect the network"
    cmd "docker network inspect inception_inception"
    docker network inspect inception_inception 2>/dev/null | grep -E '"Name"|"Subnet"|"Gateway"|"IPv4Address"'

    question "What is a Docker network and why do we use one?" \
        "A virtual private network that lets containers communicate by container name" \
        "Without it, containers are isolated and can't reach each other at all" \
        "With it: wordpress resolves 'mariadb' to the right IP automatically (Docker DNS)" \
        "Only nginx:443 is exposed to the outside — db and php-fpm are network-internal only"

    summary
}

section_7() {
    section_banner "7 · NGINX WITH SSL/TLS"

    sub "Dockerfile"
    cmd "cat srcs/requirements/nginx/Dockerfile"
    cat srcs/requirements/nginx/Dockerfile
    check "NGINX Dockerfile exists" $(test -f srcs/requirements/nginx/Dockerfile && echo 1 || echo 0)

    sub "Container running"
    cmd "docker compose -f srcs/docker-compose.yml -p inception ps nginx"
    docker compose -f srcs/docker-compose.yml -p inception ps nginx 2>/dev/null
    check "NGINX container is running" $(docker ps --format '{{.Names}}' | grep -c "^nginx$")

    sub "HTTP blocked / HTTPS works"
    cmd "curl -v http://${DOMAIN} 2>&1 | head -5"
    RES=$(curl -s --max-time 3 http://${DOMAIN} > /dev/null 2>&1 && echo 1 || echo 0)
    checkz "Cannot connect via HTTP (port 80)"                          $RES
    check  "https://${DOMAIN} shows WordPress"                          $(curl -sk https://${DOMAIN} 2>/dev/null | grep -ci "WordPress\|wp-")

    sub "TLS version verification"
    cmd "echo | openssl s_client -connect ${DOMAIN}:443 -tls1_2 2>/dev/null | grep Protocol"
    echo | openssl s_client -connect ${DOMAIN}:443 -tls1_2 2>/dev/null | grep "Protocol"
    cmd "echo | openssl s_client -connect ${DOMAIN}:443 -tls1_3 2>/dev/null | grep Protocol"
    echo | openssl s_client -connect ${DOMAIN}:443 -tls1_3 2>/dev/null | grep "Protocol"
    check "TLSv1.2 or TLSv1.3 confirmed" $(echo | openssl s_client -connect ${DOMAIN}:443 2>/dev/null | grep -cE "TLSv1\.[23]")
    note "Evaluator may try TLS 1.1 to confirm it is rejected:"
    cmd "echo | openssl s_client -connect ${DOMAIN}:443 -tls1_1 2>&1 | grep -iE 'error|alert|unsupported'"
    echo | openssl s_client -connect ${DOMAIN}:443 -tls1_1 2>&1 | grep -iE 'error|alert|unsupported' || note "(TLS 1.1 rejected — correct)"

    question "What is FastCGI and why does NGINX use fastcgi_pass?" \
        "NGINX cannot execute PHP — it's a web server, not a PHP interpreter" \
        "FastCGI = protocol to forward requests to an external process (php-fpm)" \
        "NGINX receives .php request → forwards to wordpress:9000 → gets HTML back → returns it"

    question "Why is NGINX the ONLY entrypoint into the infrastructure?" \
        "Only port 443 is mapped in docker-compose:  ports: - '443:443'" \
        "MariaDB (3306) and WordPress (9000) have NO ports mapped — unreachable from outside" \
        "All traffic MUST go through:  browser → nginx:443 → wordpress:9000 → mariadb:3306"

    summary
}

section_8() {
    section_banner "8 · WORDPRESS + PHP-FPM + VOLUME"

    sub "Dockerfile"
    cmd "cat srcs/requirements/wordpress/Dockerfile"
    cat srcs/requirements/wordpress/Dockerfile
    check  "WordPress Dockerfile exists"                    $(test -f srcs/requirements/wordpress/Dockerfile && echo 1 || echo 0)
    checkz "No NGINX in WordPress Dockerfile"               $(grep -ci "nginx" srcs/requirements/wordpress/Dockerfile 2>/dev/null || echo 0)

    sub "Container running"
    cmd "docker compose -f srcs/docker-compose.yml -p inception ps wordpress"
    docker compose -f srcs/docker-compose.yml -p inception ps wordpress 2>/dev/null
    check "WordPress container is running" $(docker ps --format '{{.Names}}' | grep -c "^wordpress$")

    sub "Volume — path must contain /home/${LOGIN}/data/"
    cmd "docker volume ls"
    docker volume ls
    cmd "docker volume inspect inception_vol_wp"
    docker volume inspect inception_vol_wp 2>/dev/null
    check "wp volume path contains /home/${LOGIN}/data/" $(docker volume inspect inception_vol_wp 2>/dev/null | grep -c "/home/${LOGIN}/data")

    sub "WordPress users"
    cmd "docker exec wordpress wp user list --allow-root --path=/var/www/html"
    docker exec wordpress wp user list --allow-root --path=/var/www/html 2>/dev/null
    check  "Admin user '${LOGIN}' exists"                 $(docker exec wordpress wp user get ${LOGIN} --allow-root --path=/var/www/html > /dev/null 2>&1 && echo 1 || echo 0)
    checkz "Admin username does NOT contain 'admin'"      $(docker exec wordpress wp user list --allow-root --path=/var/www/html --field=user_login 2>/dev/null | grep -ci "admin")
    check  "Second user 'wolfsburg' exists"               $(docker exec wordpress wp user get wolfsburg --allow-root --path=/var/www/html > /dev/null 2>&1 && echo 1 || echo 0)

    question "Add a comment as wolfsburg — verify it appears on the site" \
        "Log in at https://${DOMAIN}/wp-admin as wolfsburg" \
        "Go to any post → add a comment → check front-end"

    question "Sign in as ${LOGIN} (admin) — dashboard must be accessible" \
        "Log in at https://${DOMAIN}/wp-admin as ${LOGIN}"

    question "Edit a page as admin — verify change appears on the front-end" \
        "Dashboard → Pages → edit any page → Update → visit https://${DOMAIN}"

    summary
}

section_9() {
    section_banner "9 · MARIADB + VOLUME"

    sub "Dockerfile"
    cmd "cat srcs/requirements/mariadb/Dockerfile"
    cat srcs/requirements/mariadb/Dockerfile
    check  "MariaDB Dockerfile exists"                   $(test -f srcs/requirements/mariadb/Dockerfile && echo 1 || echo 0)
    checkz "No NGINX in MariaDB Dockerfile"              $(grep -ci "nginx" srcs/requirements/mariadb/Dockerfile 2>/dev/null || echo 0)

    sub "Container running"
    cmd "docker compose -f srcs/docker-compose.yml -p inception ps mariadb"
    docker compose -f srcs/docker-compose.yml -p inception ps mariadb 2>/dev/null
    check "MariaDB container is running" $(docker ps --format '{{.Names}}' | grep -c "^mariadb$")

    sub "Volume — path must contain /home/${LOGIN}/data/"
    cmd "docker volume inspect inception_vol_db"
    docker volume inspect inception_vol_db 2>/dev/null
    check "db volume path contains /home/${LOGIN}/data/" $(docker volume inspect inception_vol_db 2>/dev/null | grep -c "/home/${LOGIN}/data")

    sub "Database login"
    question "How do you log in to the database? (evaluator will ask you to demonstrate)" \
        "docker exec -it mariadb mariadb -u ${LOGIN} -p wordpress" \
        "Enter your DB password — you must get a MariaDB prompt"
    cmd "docker exec -it mariadb mariadb -u ${LOGIN} -p wordpress"
    check "${LOGIN} can connect to wordpress database" $(docker exec mariadb mariadb -u ${LOGIN} -p"${DB_PASS}" wordpress -e "SELECT 1;" > /dev/null 2>&1 && echo 1 || echo 0)

    sub "Database not empty — must have WordPress tables"
    cmd "docker exec mariadb mariadb -u ${LOGIN} -p<pass> wordpress -e 'SHOW TABLES;'"
    docker exec mariadb mariadb -u ${LOGIN} -p"${DB_PASS}" wordpress -e "SHOW TABLES;" 2>/dev/null
    TABLE_COUNT=$(docker exec mariadb mariadb -u ${LOGIN} -p"${DB_PASS}" wordpress -e "SHOW TABLES;" 2>/dev/null | wc -l)
    check "WordPress database has tables (not empty)" $TABLE_COUNT
    note "Expect ~12 tables: wp_posts, wp_users, wp_options, wp_comments, etc."

    summary
}

section_10() {
    section_banner "10 · PERSISTENCE"

    sub "Data exists on host machine right now"
    cmd "ls /home/${LOGIN}/data/vol_db"
    ls /home/${LOGIN}/data/vol_db 2>/dev/null | head -5
    check "Data exists in /home/${LOGIN}/data/vol_db" $(ls /home/${LOGIN}/data/vol_db 2>/dev/null | wc -l)

    cmd "ls /home/${LOGIN}/data/vol_wp"
    ls /home/${LOGIN}/data/vol_wp 2>/dev/null | head -5
    check "Data exists in /home/${LOGIN}/data/vol_wp" $(ls /home/${LOGIN}/data/vol_wp 2>/dev/null | wc -l)

    sub "Persistence test steps (done with evaluator)"
    note "1.  Make a visible change in WordPress (edit a page, add a comment)"
    note "2.  Run:  sudo reboot"
    note "3.  After VM restarts:  cd ~/Documents/inception && make"
    note "4.  Open https://${DOMAIN} — your changes must still be there"
    note "5.  Run:  docker exec -it mariadb mariadb -u ${LOGIN} -p wordpress"
    note "         → SHOW TABLES;  must show ~12 tables"
    note ""
    note "Why it works: data lives in /home/${LOGIN}/data/ ON THE HOST"
    note "Containers come and go — host filesystem persists across reboots"

    question "Why does persistence work even after 'make fclean'?" \
        "It doesn't — fclean runs 'sudo rm -rf /home/${LOGIN}/data' which deletes everything" \
        "Persistence survives REBOOTS (containers stop, host data stays)" \
        "fclean is for dev cleanup only — evaluator uses 'sudo reboot' not fclean"

    summary
}

run_all() {
    section_1
    section_2
    section_3
    section_4
    section_5
    section_6
    section_7
    section_8
    section_9
    section_10

    echo -e "\n${BOLD}${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}           ALL SECTIONS COMPLETE                  ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}                                                  ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  Remaining manual checks:                        ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${GRAY}□  Open https://${DOMAIN} in browser${NC}         ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${GRAY}□  Confirm http:// is blocked${NC}                ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${GRAY}□  Add comment as wolfsburg${NC}                  ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${GRAY}□  Edit a page as ${LOGIN}${NC}                    ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${GRAY}□  sudo reboot → make → verify persistence${NC}   ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════╝${NC}\n"
}

# ── Main Menu Loop ────────────────────────────────────────────────────────────

while true; do
    show_menu
    read -r choice
    case "$choice" in
        0)  run_all ;;
        1)  section_1 ;;
        2)  section_2 ;;
        3)  section_3 ;;
        4)  section_4 ;;
        5)  section_5 ;;
        6)  section_6 ;;
        7)  section_7 ;;
        8)  section_8 ;;
        9)  section_9 ;;
        10) section_10 ;;
        q|Q) echo -e "\n  ${CYAN}Good luck on your eval! 🎉${NC}\n"; exit 0 ;;
        *)  echo -e "\n  ${RED}Invalid choice — pick 0–10 or q${NC}" ;;
    esac
    echo -ne "\n  ${DIM}Press Enter to return to menu...${NC}"
    read -r
done