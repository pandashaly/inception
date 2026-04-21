#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

OK="${GREEN}OK${RESET}"
FAIL="${RED}FAIL${RESET}"

PASS=$(cat secrets/db_password.txt)
ROOT_PASS=$(cat secrets/db_root_password.txt)

# =============================================================================
# MANUAL CHECKS (evaluator reads files directly — can't automate these)
# =============================================================================
# - Open srcs/requirements/mariadb/Dockerfile and confirm:
#     * First line is FROM alpine:3.20 (or debian equivalent) — NOT alpine:latest
#     * No passwords written anywhere in the file
#     * No nginx installed
#     * ENTRYPOINT runs a script, not a daemon directly
# - Evaluator will ask you to EXPLAIN how to log into the database
#     * Be ready to say: docker exec -it mariadb mariadb -u <user> -p <dbname>
# - Evaluator will ask you to explain what MariaDB is and why it's in its own container
# - Be ready to explain what a Docker volume is and why we use named volumes
#   instead of bind mounts (named volumes are managed by Docker, portable,
#   while bind mounts depend on host path existing and are less portable)
# =============================================================================

echo "=== MariaDB Tests ==="

# Eval sheet: "using docker compose ps, ensure the container was created"
# Know this command by heart — evaluator will ask you to run it
echo -n "[1] Container running... "
docker ps --format '{{.Names}}' | grep -q "^mariadb$" && echo -e "$OK" || echo -e "$FAIL"

# Eval sheet: "the evaluated student must be able to explain how to login into the database"
# This proves your DB user was created correctly with the right password
# Be ready to explain: -u is the user, -p prompts for password, last arg is the database
echo -n "[2] ssottori user can connect... "
docker exec mariadb mariadb -u ssottori -p"$PASS" wordpress -e "SELECT 1;" > /dev/null 2>&1 && echo -e "$OK" || echo -e "$FAIL"

# Eval sheet: "verify that the database is not empty"
# NOTE: right now the DB IS empty (no WordPress tables yet) — this check is
# really only meaningful after Phase 5 when WordPress has fully set up.
# After full setup, run: SHOW TABLES; inside the wordpress DB — you should
# see ~12 WordPress tables (wp_posts, wp_users, wp_options, etc.)
echo -n "[3] wordpress database exists... "
docker exec mariadb mariadb -u ssottori -p"$PASS" -e "SHOW DATABASES;" 2>/dev/null | grep -q "wordpress" && echo -e "$OK" || echo -e "$FAIL"

# Subject: "there must be two users, one being the administrator"
# Root is the DB superuser — evaluator may ask you to prove root access works
# and ask you to explain the difference between root and the wordpress user
echo -n "[4] root password works... "
docker exec mariadb mariadb -u root -p"$ROOT_PASS" -e "SELECT 1;" > /dev/null 2>&1 && echo -e "$OK" || echo -e "$FAIL"

# Security check — your wordpress user should only have access to the wordpress DB
# If this FAILS (ssottori CAN access mysql), your GRANT was too broad
# Be ready to explain: we used GRANT ALL ON wordpress.* (not ON *.*)
echo -n "[5] ssottori cannot access system DBs... "
docker exec mariadb mariadb -u ssottori -p"$PASS" -e "USE mysql;" > /dev/null 2>&1 && echo -e "${RED}FAIL (too much access)${RESET}" || echo -e "$OK"

# Eval sheet: "run docker volume ls" — evaluator does this visually
# Volume name must exist and follow the pattern <project>_vol_db
echo -n "[6] volume exists with correct name... "
docker volume ls --format '{{.Name}}' | grep -q "inception_vol_db" && echo -e "$OK" || echo -e "$FAIL"

# Eval sheet: "run docker volume inspect <name>, verify result contains /home/login/data/"
# This is a hard requirement — evaluator literally checks for this string
# Be ready to explain: driver_opts type:none + o:bind makes a named volume
# backed by a specific host path (not a regular bind mount in the service definition)
echo -n "[7] volume data stored at correct path... "
docker volume inspect inception_vol_db 2>/dev/null | grep -q "/home/ssottori/data" && echo -e "$OK" || echo -e "$FAIL"

# Required for WordPress (in another container) to reach MariaDB over the Docker network
# Default MariaDB binds to 127.0.0.1 — that's localhost INSIDE the container only
# Be ready to explain: containers have separate network namespaces, so
# localhost in mariadb container ≠ localhost in wordpress container
echo -n "[8] bind-address is 0.0.0.0... "
docker exec mariadb mariadb -u root -p"$ROOT_PASS" -e "SHOW VARIABLES LIKE 'bind_address';" 2>/dev/null | grep -q "0.0.0.0" && echo -e "$OK" || echo -e "$FAIL"

# Eval sheet explicitly says to run docker compose ps — know this command
# -p inception because that's the project name set in your Makefile
echo -n "[9] docker compose ps shows mariadb running... "
docker compose -f srcs/docker-compose.yml -p inception ps --services --filter "status=running" 2>/dev/null | grep -q "mariadb" && echo -e "$OK" || echo -e "$FAIL"

# Eval sheet: "ensure there is no NGINX in the Dockerfile"
# Each container must have ONE service only — this is a hard eval failure if wrong
echo -n "[10] nginx NOT installed in container... "
docker exec mariadb which nginx > /dev/null 2>&1 && echo -e "${RED}FAIL (nginx found!)${RESET}" || echo -e "$OK"

echo "====================="
# After this eval section the evaluator clicks YES only if ALL points are correct.
# One failure = the evaluation ends here.