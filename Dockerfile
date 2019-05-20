# execute with:
# sudo docker build --build-arg RELEASE=<version number, example x.x.x> -t davidezanin/demodocker:vx.x.x . 
FROM ubuntu

LABEL maintainer="davide.zanin@supsi.ch"

ARG RELEASE=1.0.0

ENV RELEASE_VERSION=${RELEASE}

# update, install python3.7, pip3, postgresql
RUN apt-get -y update &&\
    apt-get -y install python3.7 &&\
    apt-get -y install python3-pip &&\
    DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql postgresql-contrib


RUN apt-get -y install wget &&\
    wget https://github.com/dzanin/dockerdemo/archive/${RELEASE_VERSION}.tar.gz &&\
    tar xvzf ${RELEASE_VERSION}.tar.gz &&\
    mkdir /usr/src/app &&\
    cp -r dockerdemo-${RELEASE_VERSION}/app/* /usr/src/app 


# Create app directory
WORKDIR /usr/src/app

# Install requirements
RUN  pip3 install -r requirements.txt

# Run the rest of the commands as the ``postgres`` user 
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password, 
# set the time zone, and then create a database `docker` owned by the ``docker
# ``role. 
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker'; SET TIME ZONE 'Europe/Zurich'" &&\
    createdb -O docker docker &&\
    psql -U postgres -d docker -a -f table.sql 
#   PGPASSWORD=docker psql -d docker -U docker -w

#     psql --command "CREATE TABLE account(
#  user_id serial PRIMARY KEY,
#  username VARCHAR (50) UNIQUE NOT NULL,
#  password VARCHAR (50) NOT NULL,
#  email VARCHAR (355) UNIQUE NOT NULL,
#  created_on TIMESTAMP NOT NULL,
#  last_login TIMESTAMP
# ); 
#     ALTER TABLE  OWNER TO <username>"


# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]    

# Run the rest of the commands as the ``root`` user
USER root

# To log in with ident based authentication, you'll need a Linux user 
# with the same name as your Postgres role and database.
#RUN adduser docker 


# COPY /usr/src/source/app /usr/src/app


EXPOSE 80

CMD [ "python", "app.py" ]
