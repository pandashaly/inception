#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"
OK="${GREEN}OK${RESET}"
FAIL="${RED}FAIL${RESET}"

echo "=== NGINX Tests ==="

# Eval: "ensure there is a Dockerfile" + "container was created"
echo -n "[1] Container running... "
docker ps --format '{{.Names}}' | grep -q "^nginx$" && echo -e "$OK" || echo -e "$FAIL"

# Eval: "NGINX can be accessed by port 443 only"
echo -n "[2] HTTPS on port 443 works... "
curl -sk https://ssottori.42.fr | grep -q "WordPress\|wp-" && echo -e "$OK" || echo -e "$FAIL"

# Eval: "you should not be able to access the site via http"
echo -n "[3] HTTP port 80 is blocked... "
curl -s --max-time 3 http://ssottori.42.fr > /dev/null 2>&1 && echo -e "${RED}FAIL (port 80 accessible!)${RESET}" || echo -e "$OK"

# Eval: "ensure that a SSL/TLS certificate is used"
echo -n "[4] SSL certificate present... "
echo | openssl s_client -connect ssottori.42.fr:443 2>/dev/null | grep -q "CERTIFICATE" && echo -e "$OK" || echo -e "$FAIL"

# Subject: "TLSv1.2 or TLSv1.3 only"
echo -n "[5] TLSv1.2 or TLSv1.3 in use... "
echo | openssl s_client -connect ssottori.42.fr:443 2>/dev/null | grep -qE "TLSv1\.[23]" && echo -e "$OK" || echo -e "$FAIL"

# Eval: "no NGINX in the Dockerfile" does not apply here — nginx IS this container
# But confirm no extra services are running inside it
echo -n "[6] only nginx running in container... "
docker exec nginx ps aux 2>/dev/null | grep -v "nginx\|PID\|ps" | grep -q "." && echo -e "${RED}FAIL (extra processes)${RESET}" || echo -e "$OK"

# Eval: TLS certificate — check CN matches domain
echo -n "[7] certificate CN matches domain... "
echo | openssl s_client -connect ssottori.42.fr:443 2>/dev/null | openssl x509 -noout -subject 2>/dev/null | grep -q "ssottori.42.fr" && echo -e "$OK" || echo -e "$FAIL"

echo "==================="
# MANUAL CHECKS for eval:
# - Dockerfile starts FROM alpine:3.20 (not latest)
# - No passwords in Dockerfile
# - Evaluator will ask: "why is NGINX the only entrypoint?"
#   Answer: only port 443 is mapped in docker-compose. MariaDB and WordPress
#   have no ports exposed to the host — they're only reachable within the Docker network
# - Evaluator will ask: "what is FastCGI / why fastcgi_pass?"
#   Answer: FastCGI is a protocol for passing requests to an external process (php-fpm).
#   NGINX can't execute PHP itself — it hands .php files to php-fpm and returns the result
# - Evaluator may run: openssl s_client -connect ssottori.42.fr:443
#   to verify TLS version. Know how to read that output.