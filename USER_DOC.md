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

### NGINX
NGINX is the only service exposed to the outside. It listens on port 443 and handles HTTPS access to the website.

### WordPress
WordPress contains the website content and the admin dashboard. This is where the pages, users, posts, and comments are managed.

### MariaDB
MariaDB stores the WordPress data. That includes users, settings, posts, comments, and everything else saved by the site.

## How to start the project

From the root of the repository, run:

```bash
make
