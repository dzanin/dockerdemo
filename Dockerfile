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
ARG RELEASE=7.1.0
ENV RELEASE_VERSION=${RELEASE}
ENV DB_USER='docker'
ENV DB_NAME='docker'
ENV TZ 'Europe/Rome'
RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

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
    apt-get install -y pwgen &&\
    apt-get -y install nano

# RUN DB_PASS=$(pwgen) &&\
#     echo $DB_PASS
# ENV DBX_PASS=$DB_PASS

RUN echo ${DBX_PASS}

# Switch to app directory
WORKDIR /usr/src/app

# Install requirements, add user/group docker
RUN  python3.7 -m pip install -r requirements.txt &&\
     set -eux; \
	 groupadd -r ${DB_USER} --gid=1001; \
	 useradd -r -g ${DB_USER} --uid=1001 --no-create-home ${DB_USER}; 


# Run the rest of the commands as the ``postgres`` user 
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password, 
# set the time zone, and then create a database `docker` owned by the ``docker
# ``role. 
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN /etc/init.d/postgresql start &&\
    DB_PASS=$(pwgen) &&\
    echo $DB_PASS &&\
    psql --command "CREATE USER ${DB_USER} WITH PASSWORD '$DB_PASS'; SET TIME ZONE '${TZ}';" &&\
    createdb -O ${DB_USER} ${DB_NAME} &&\
    psql -U postgres -d ${DB_NAME} -a -f table.sql 
#   PGPASSWORD=docker psql -d docker -U docker -w
#RUN echo "local   all             docker                                  md5" >> /etc/postgresql/10/main/pg_hba.conf

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]    

USER root

# COPY /usr/src/source/app /usr/src/app
RUN chmod +x my_wrapper_script.sh &&\
    rm /etc/nginx/sites-enabled/default &&\
    mkdir -p /var/www/example.com/html &&\
    chown -R $USER:$USER /var/www/example.com/html &&\
    mv index.html /var/www/example.com/html/ &&\
    mv example.com /etc/nginx/sites-available/ &&\
    ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/ 
RUN mv proxy.conf /etc/nginx/




# ENTRYPOINT ["/bin/bash", "-c", "service postgresql start", ]

# Run the rest of the commands as the ``root`` user

EXPOSE 80

#/usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/main -l logfile start
#ENTRYPOINT ["/bin/bash", "-c", "service postgresql start && service nginx start" ]
#"&&", "service", "nginx", "start", "&&", "python3.7", "app.py"]
#CMD ["/bin/bash", "-c", "service nginx start"]
#CMD ["/bin/bash", "-c","service nginx start", "&&", "/usr/lib/postgresql/10/bin/postgres", "-D", "/var/lib/postgresql/10/main", "-c", "config_file=/etc/postgresql/10/main/postgresql.conf"]
CMD ["./my_wrapper_script.sh"]