# Build with (x.x.x means release version number):
# sudo docker build --build-arg RELEASE=x.x.x -t davidezanin/demodocker:vx.x.x . 
# Test with:
# sudo docker run -it --rm --name demodockerContainer -p 8080:80 davidezanin/demodocker:vx.x.x /bin/sh 
# Run with:
# sudo docker run --name demodockerContainer -p 8080:80 davidezanin/demodocker:vx.x.x

FROM ubuntu

LABEL maintainer="davide.zanin@supsi.ch"

# Setting a default arg that become an env variable,
# you can passing it during build with --build-arg RELEASE=x.x.x
ARG RELEASE=7.0.0
ENV RELEASE_VERSION=${RELEASE}

# Update, install python3.7, postgresql, download release passed as arg and copy in /usr/src/app
RUN apt-get -y update &&\
    apt-get -y install python3.7 &&\
    apt-get -y install python3-pip &&\
    DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql postgresql-contrib &&\
    apt-get -y install wget &&\
    wget https://github.com/dzanin/dockerdemo/archive/${RELEASE_VERSION}.tar.gz &&\
    tar xvzf ${RELEASE_VERSION}.tar.gz &&\
    mkdir /usr/src/app &&\
    cp -r dockerdemo-${RELEASE_VERSION}/app/* /usr/src/app  &&\
    apt-get -y install nginx &&\
    apt-get -y install nano

# Switch to app directory
WORKDIR /usr/src/app

# Install requirements, add user/group docker
RUN  python3.7 -m pip install -r requirements.txt &&\
     set -eux; \
	 groupadd -r docker --gid=1001; \
	 useradd -r -g docker --uid=1001 --no-create-home docker; 


# Run the rest of the commands as the ``postgres`` user 
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password, 
# set the time zone, and then create a database `docker` owned by the ``docker
# ``role. 
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker'; SET TIME ZONE 'Europe/Zurich';" &&\
    createdb -O docker docker &&\
    psql -U postgres -d docker -a -f table.sql 
#   PGPASSWORD=docker psql -d docker -U docker -w
#RUN echo "local   all             docker                                  md5" >> /etc/postgresql/10/main/pg_hba.conf

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]    

USER root

# COPY /usr/src/source/app /usr/src/app
RUN chmod +x my_wrapper_script.sh

#ENTRYPOINT ["/bin/bash", "-c", "service postgresql start", ]

# Run the rest of the commands as the ``root`` user

EXPOSE 80

#/usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/main -l logfile start
#ENTRYPOINT ["/bin/bash", "-c", "service postgresql start && service nginx start" ]
#"&&", "service", "nginx", "start", "&&", "python3.7", "app.py"]
#CMD ["/bin/bash", "-c", "service nginx start"]
#CMD ["/bin/bash", "-c","service nginx start", "&&", "/usr/lib/postgresql/10/bin/postgres", "-D", "/var/lib/postgresql/10/main", "-c", "config_file=/etc/postgresql/10/main/postgresql.conf"]
CMD ["./my_wrapper_script.sh"]