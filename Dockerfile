FROM ubuntu

LABEL maintainer="davide.zanin@supsi.ch"

#update
RUN apt-get -y update

#install python3.7 and pip3
RUN apt-get -y install python3.7 
RUN apt-get -y install python3-pip

#install postgresql
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql postgresql-contrib

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
    psql --command "CREATE TABLE playground (
    equip_id serial PRIMARY KEY,
    type varchar (50) NOT NULL,
    color varchar (25) NOT NULL,
    location varchar(25) check (location in ('north', 'south', 'west', 'east', 'northeast', 'southeast', 'southwest', 'northwest')),
    install_date date) ; 
    ALTER TABLE  OWNER TO <username>"


# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]    

# Run the rest of the commands as the ``root`` user
USER root

# To log in with ident based authentication, you'll need a Linux user 
# with the same name as your Postgres role and database.
#RUN adduser docker 


COPY app /usr/src/app

# Create app directory
WORKDIR /usr/src/app

RUN pip3 install -r requirements.txt

EXPOSE 80

CMD [ "python", "app.py" ]
