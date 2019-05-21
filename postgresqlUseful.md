# list user

From within psql:

`\du`
From the terminal:

`psql -c '\du'`

Replace peer with md5 on local
`sudo nano /etc/postgresql/9.3/main/pg_hba.conf`

Run psql without password
`PGPASSWORD=docker psql -d docker -U docker -w`

RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf

/usr/lib/postgresql/10/bin/postgres -D /var/lib/postgresql/10/main -c config_file=/etc/postgresql/10/main/postgresql.conf
