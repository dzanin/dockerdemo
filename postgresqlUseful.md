# list user

From within psql:

`\du`
From the terminal:

`psql -c '\du'`

Replace peer with md5 on local
`sudo nano /etc/postgresql/9.3/main/pg_hba.conf`

Run psql without password
`PGPASSWORD=docker psql -d docker -U docker -w`