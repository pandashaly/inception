# Developer Documentation

This document explains how to set up, build, and manage the Inception project from scratch.

## 1. Environment Setup

### Prerequisites

Before starting, make sure the following are installed on your system...otherwise a lot of things are not going to work:

- Docker (installed via apt — not snap, snap causes AppArmor issues and is generally a nightmare)
- A Linux VM (I used Ubuntu just like the school machines in VMWare)
- Docker Compose
- Make
- Git
- Any text editor (to set variables in `.env` and fill in the `secrets/` folder)

### Configuration Files and Secrets

##### 1. `.env` file

Contains all environment variables used by Docker Compose and the container scripts:

```
DOMAIN_NAME=ssottori.42.fr
DB_NAME=wordpress
DB_USER=ssottori
WP_ADMIN_LOGIN=ssottori
WP_ADMIN_EMAIL=ssottori@student.42wolfsburg.de
WP_ADMIN_TITLE=Inception
WP_USER_LOGIN=wolfsburg
WP_USER_EMAIL=wolfsburg@student.42wolfsburg.de
```

##### 2. Place the `.env` file inside the `srcs/` directory.

##### 3. Make sure `.env` is **not tracked in Git** (add it to `.gitignore`). - for this project specifically, i added them to a .example file.

##### 4. Passwords go in the `secrets/` folder

Each file contains one password (just the password, nothing else):

```
secrets/
├── db_password.txt         ← WordPress DB user password
├── db_root_password.txt    ← MariaDB root password
├── wp_admin_password.txt   ← WordPress admin password
└── wp_user_password.txt    ← WordPress second user password
```

Make sure `secrets/` is also in `.gitignore` — **never commit passwords to git**.

---

## 2. Building and Launching the Project

### Using the Makefile

The Makefile handles everything. These are the commands you'll actually use:

- **Build images and start containers**
`make`

- **Start containers after stopping them**
`make up`

- **Stop and remove containers**
`make down`

- **Rebuild everything from scratch**
`make re`

- **Stop and remove absolutely everything**
`make fclean`

> ⚠️ `make fclean` **deletes all saved data** (volumes, database, WordPress files). Only use it when you actually want a clean slate.

### Using Docker Compose Directly

If you want more control:

- **Build and start**
`docker compose -f srcs/docker-compose.yml -p inception up -d --build`

- **Stop and remove**
`docker compose -f srcs/docker-compose.yml -p inception down`

- **Rebuild a single service**
`docker compose -f srcs/docker-compose.yml -p inception build <service_name>`

---

## 3. Managing Containers and Volumes

### Containers

List all running containers:
`docker ps`

View logs for a container:
`docker logs <container_name>`

Open a shell inside a container (useful for debugging):
`docker exec -it <container_name> sh`

Connect to the database directly:
`docker exec -it mariadb mariadb -u ssottori -p wordpress`

### Volumes

List all volumes:
`docker volume ls`

Inspect a volume (see where data is stored on the host):
`docker volume inspect inception_vol_db`
`docker volume inspect inception_vol_wp`

Remove unused volumes (careful with this one):
`docker volume prune`

---

## 4. Data Storage and Persistence

All persistent data is stored in named Docker volumes that are backed by real folders on the host machine:

```
/home/ssottori/data/vol_db/   ← MariaDB database files
/home/ssottori/data/vol_wp/   ← WordPress files
```

Because the data lives on the host filesystem, it survives container restarts and VM reboots. The containers themselves are stateless — if you remove and recreate them, your data is still there.

The only thing that wipes the data is `make fclean`, which deletes those folders entirely.

## Useful commands

```bash
# Go inside a container
docker exec -it mariadb sh
docker exec -it wordpress sh
docker exec -it nginx sh

# Connect to the database
docker exec -it mariadb mariadb -u ssottori -p wordpress

# Check volumes
docker volume ls
docker volume inspect inception_vol_db
docker volume inspect inception_vol_wp

# Check the network
docker network inspect inception_inception

# View logs
docker logs mariadb
docker logs wordpress
docker logs nginx
```