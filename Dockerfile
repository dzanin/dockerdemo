# Build with (x.x.x means release version number):
# sudo docker build --build-arg RELEASE=x.x.x -t davidezanin/demodocker:vx.x.x . 
# Test with:
# sudo docker run -it --rm --name demodockerContainer -p 80:80 davidezanin/demodocker:vx.x.x /bin/sh 
# Run with:
# sudo docker run --name demodockerContainer -p 8080:80 davidezanin/demodocker:vx.x.x

FROM ubuntu

LABEL maintainer="davide.zanin@supsi.ch"

# Setting default args that become an env variable,
# you can passing it during build with --build-arg RELEASE=x.x.x
# Setting Release, Time Zone and DB parameters
ARG A_RELEASE=7.1.3
ARG A_DB_USER='docker'
ARG A_DB_PASS='docker'
ARG A_DB_NAME='docker'
ARG A_TZ='Europe/Rome'

ENV RELEASE_VERSION=${A_RELEASE}
ENV DB_USER=${A_DB_USER}
ENV DB_PASS=${A_DB_PASS}
ENV DB_NAME=${A_DB_NAME}
ENV TZ=${A_TZ}

# Adjusting Timezone in the system
RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

# Update, install python3.7, postgresql, nginx download release passed as arg and copy in /usr/src/app
RUN apt-get -y update &&\
    apt-get -y install python3.7 &&\
    apt-get -y install python3-pip &&\
    DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql postgresql-contrib &&\
    apt-get -y install wget &&\
    wget https://github.com/dzanin/dockerdemo/archive/${RELEASE_VERSION}.tar.gz &&\
    tar xvzf ${RELEASE_VERSION}.tar.gz &&\
    mkdir -p /usr/src/bms/api &&\
    mv dockerdemo-${RELEASE_VERSION}/app/* /usr/src/bms/api/  &&\
    apt-get -y install nginx &&\
    apt-get -y install nano

# Switch to app directory
WORKDIR /usr/src/bms/api

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
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}'; SET TIME ZONE '${TZ}';" &&\
    createdb -O ${DB_USER} ${DB_NAME} &&\
    psql -U postgres -d ${DB_NAME} -a -f db/table.sql

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]    

# Run the rest of the commands as the ``root`` user 
USER root


RUN chmod +x config/my_wrapper_script.sh &&\
    rm /etc/nginx/sites-enabled/default &&\
    mkdir -p /var/www/example.com/html &&\
#    chown -R $USER:$USER /var/www/example.com/html &&\
#    mv html/index.html /var/www/example.com/html/ &&\
    chown -R $USER:$USER /usr/src/bms/api/html &&\
    mv config/example.com /etc/nginx/sites-available/ &&\
    mv config/proxy.conf /etc/nginx/proxy.conf &&\
    ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/ 

#ENTRYPOINT [ "./my_wrapper_script.sh" ]

# Expose port 80
EXPOSE 80

CMD ["./config/my_wrapper_script.sh"]