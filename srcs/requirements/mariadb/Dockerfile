FROM alpine:3.20
RUN apk update && apk add --no-cache mariadb mariadb-client
RUN mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld
COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh
EXPOSE 3306
ENTRYPOINT ["/init_db.sh"]