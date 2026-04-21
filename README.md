*This project has been created as part of the 42 curriculum by ssottori and gave her many many many headaches. Also, snap sucks!*

# Inception

## Description

Inception is a 42 project where I had to set up a small web infrastructure using Docker and build containers from scratch. Instead of installing everything directly on a machine, I containerized each service so they run in isolation and talk to each other over a private network through nginx.

The stack has three services:
- **NGINX** - the only way in from the outside, serves the site over HTTPS on port 443 
- **WordPress + php-fpm** - the actual website, with php-fpm handling the PHP execution
- **MariaDB** — the database where all the WordPress content is stored

Each service has its own Docker image built from scratch using Alpine 3.20. We were instructed to use the *penultimate version* on the subject pdf, hence why I used this one.
I chose alpine over Debian because I had used Debian in my B@BR project and wanted to try using alpine instead. Also Alpine is lighter than debian.

### Design choices

**Virtual Machines vs Docker**
VMs emulate full hardware so they're heavy and slow. Docker containers share the host kernel which makes them way lighter and faster to start. You still get isolation between services, just without all the overhead.

**Secrets vs Environment Variables**
I keep non-sensitive config (usernames, domain, DB name) in a `.env` file. Actual passwords go in separate files inside `secrets/` — Docker mounts them inside the container at `/run/secrets/` so they're never visible in the compose file or `docker inspect`.
I have also added env.example to facilitate setup.

**Docker Network vs Host Network**
Host network removes isolation between the container and the host. Instead I use a custom bridge network so the containers can reach each other by name (e.g. `wordpress` can connect to `mariadb` by just using the name `mariadb`), and nothing is exposed to the outside except NGINX on port 443.

**Docker Volumes vs Bind Mounts**
Bind mounts directly link a host folder to a container but we are not allowed to use bind mounts for this project, so I use named volumes instead, but configure them with `driver_opts` to store the actual data at `/home/ssottori/data/` on the host. This way the data survives reboots and I still meet both requirements.

## Instructions

Make sure `/etc/hosts` has this line:
```
127.0.0.1 ssottori.42.fr
```

Then from the project root:
```bash
make          # build and start everything
make down     # stop containers
make fclean   # remove everything including data
make re       # fclean + rebuild
```

Open `https://ssottori.42.fr` in Firefox browser in the VM. You'll get a certificate warning...that's expected, just click through it.

## Resources

- [Docker docs](https://docs.docker.com/)
- [Docker Compose docs](https://docs.docker.com/compose/)
- [Alpine Linux packages](https://pkgs.alpinelinux.org/)
- [WP-CLI](https://wp-cli.org/)
- [NGINX docs](https://nginx.org/en/docs/)
- [MariaDB docs](https://mariadb.com/kb/en/)
- [php-fpm docs](https://www.php.net/manual/en/install.fpm.php)
- [Docker image vs container — CircleCI](https://circleci.com/blog/docker-image-vs-container/)
- [Bind mounts vs volumes — Stack Overflow](https://stackoverflow.com/questions/47150829/what-is-the-difference-between-binding-mounts-and-volumes-while-handling-persist)
- [docker-compose links vs depends_on — Baeldung](https://www.baeldung.com/ops/docker-compose-links-depends-on)
- [docker-compose up/down/stop/start difference — Stack Overflow](https://stackoverflow.com/questions/46428420/docker-compose-up-down-stop-start-difference)
- [RUN vs CMD vs ENTRYPOINT — Docker blog](https://www.docker.com/blog/docker-best-practices-choosing-between-run-cmd-and-entrypoint/)
- [Generating a self-signed SSL certificate with openssl — Stack Overflow](https://stackoverflow.com/questions/10175812/how-can-i-generate-a-self-signed-ssl-certificate-using-openssl)
- [Dockerfile for NGINX — Medium](https://medium.com/@mrdevsecops/dockerfile-nginx-842ba0a55b82)
- [Inception guide — Medium (@imyzf)](https://medium.com/@imyzf/inception-3979046d90a0)
- [Inception guide part I — Medium (@ssterdev)](https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671)
- [Docker + NGINX + WordPress + MariaDB tutorial — dev.to](https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok)
- [42 Inception reference project — mofrim on Codeberg](https://codeberg.org/mofrim/42-inception/src/branch/main/DEV_DOC.md)

### AI usage

I used ai during this project to help me cut time with certain tasks such as...:
- Debugging container issues (MariaDB not binding to TCP, php-fpm listening on IPv6 only)
- understanding bind and named volumes
- writing the tester scripts to help me test the project faster and more efficiently