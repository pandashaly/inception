#!/bin/sh
set -e

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/key.pem \
    -out    /etc/nginx/ssl/cert.pem \
    -subj   "/C=DE/ST=NI/L=Wolfsburg/O=42/CN=ssottori.42.fr"

exec nginx -g "daemon off;"