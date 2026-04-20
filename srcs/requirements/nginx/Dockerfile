FROM alpine:3.20

RUN apk update && apk add --no-cache nginx openssl

COPY conf/nginx.conf /etc/nginx/http.d/nginx.conf
COPY tools/nginx_setup.sh /nginx_setup.sh
RUN chmod +x /nginx_setup.sh

EXPOSE 443

ENTRYPOINT ["/nginx_setup.sh"]