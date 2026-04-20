FROM alpine:3.20

RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-phar \
    php83-session \
    php83-curl \
    php83-mbstring \
    php83-openssl \
    php83-dom \
    php83-xml \
    wget

RUN echo "memory_limit = 512M" >> /etc/php83/php.ini

RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -O /usr/local/bin/wp && chmod +x /usr/local/bin/wp

COPY tools/wp_setup.sh /wp_setup.sh
RUN chmod +x /wp_setup.sh

EXPOSE 9000

ENTRYPOINT ["/wp_setup.sh"]