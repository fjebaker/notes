# Using Gitea with MariaDB
[Gitea](https://docs.gitea.io/) is a fork of Gogs, for use as a GitHub like git host.

The [installation guide]() explains how you can configure Gitea with `docker-compose` and a MySQL database. My interest is in using MariaDB, which can require a few additional steps if the setup fails out-of-the-box.

## `docker-compose.yml`
We configure
```yml
version: "3.8"

networks:
  gitea:
    external: false

services:
  server:
    image: gitea/gitea:latest
    container_name: gitea
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - DB_TYPE=mysql
      - DB_HOST=db:3306
      - DB_NAME=gitea
      - DB_USER=gitea
      - DB_PASSWD=gitea
    restart: always
    networks:
      - gitea
    volumes:
      - ${GITEA_PATH}:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
     ports:
       - 9000:3000
       - 222:22
    depends_on:
      - db

  db:
    image: mariadb:latest
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=some_root_password
      - MYSQL_USER=gitea
      - MYSQL_PASSWORD=gitea
      - MYSQL_DATABASE=gitea
    networks:
      - gitea
    volumes:
      - ${MARIADB_PATH}:/var/lib/mysql
    ports:
      - 9090:8080
```
with two environment variables in `.env`
```
MARIADB_PATH=/path/for/mariadb/storage
GITEA_PATH=/path/for/gitea/storage
```

We can then bring the whole network online with  
```bash
docker-compose up
```

Navigate to `localhost:9000` to then finalise the gitea setup.

## Troubleshooting
If the login permissions fail on the MariaDB container, log ingo the mysql root client with 
```
docker exec -it gitea_db_1 /usr/bin/mysql -u root -p
```
and configure access for either a specific address or all (hostname `%`) with
```sql
GRANT ALL ON gitea.* TO 'gitea'@'[hostaddr]' IDENTIFIED BY '[password:gitea]' WITH GRANT OPTION;
```
And commit changes with
```
FLUSH PRIVILEGES;
EXIT;
```
