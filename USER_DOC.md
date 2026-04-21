# USER_DOC

## What this project does

This project runs a small web infrastructure using Docker.

It is made of 3 main services:

- **NGINX**: the web server that handles HTTPS requests
- **WordPress**: the website itself aswelll as the admin panel
- **MariaDB**: the database used by WordPress

Each service runs in its own container. They are separated from each other, but they work together through Docker Compose.

The goal is to have a working WordPress website running with HTTPS, a database, and persistent data storage.

## Services in the stack
### What's running

My stack runs three services:

| Service | What it does |
|---|---|
| NGINX | Handles all incoming traffic over HTTPS (port 443) |
| WordPress | The website and admin panel |
| MariaDB | The database — stores everything WordPress needs |

You can only access the site through `https://ssottori.42.fr`. The database and php-fpm are not exposed outside the containers.

### NGINX
NGINX is the only service exposed to the outside. It listens on port 443 and handles HTTPS access to the website.

### WordPress
WordPress contains the website content and the admin dashboard. This is where the pages, users, posts, and comments are managed.

### MariaDB
MariaDB stores the WordPress data. That includes users, settings, posts, comments, and everything else saved by the site.

## How to start the project


## Starting and stopping

From the root of the project:

```bash
make        # start everything (builds images if needed)
make down   # stop and remove containers (your data is kept)
make fclean # remove everything — containers, images, volumes, and data
```

## Accessing the site

- **Website:** `https://ssottori.42.fr`
- **Admin panel:** `https://ssottori.42.fr/wp-admin`

When you open it in the browser you'll get a security warning because the certificate is self-signed. Just click "Advanced" and continue. 

## Credentials

All passwords are stored as plain text files in the `secrets/` folder at the root of the project. I set up .example files but they need to be configured properly for it to work with the docker-compose.

| File | What it unlocks |
|---|---|
| `secrets/db_password.txt` | Database password for the WordPress user |
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/wp_admin_password.txt` | WordPress admin (`ssottori`) password |
| `secrets/wp_user_password.txt` | WordPress second user (`wolfsburg`) password |

## Checking that everything is running

```bash
docker ps                  # should show mariadb, wordpress, nginx all as "Up"
docker logs mariadb        # check mariadb output
docker logs wordpress      # check wordpress/php-fpm output
docker logs nginx          # check nginx output
```