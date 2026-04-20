FROM debian:bullseye
#penultimate stable version - bullseye facts Toystory

# Installing MariaDB and clean up apt cache to keep image small
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

#this dir is to store the socket files
# mysql:mysql means the mysql user owns it
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

COPY tools/init_db.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/init_db.sh

# MariaDB listens on port 3306 ??why
EXPOSE 3306

# Run our init script when the container starts
# were usiing array form (not a string) to avoid spawning an extra shell process
ENTRYPOINT ["/usr/local/bin/init_db.sh"]