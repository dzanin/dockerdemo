# dockerDemo

In this repository you can find a demo to create a docker based on ubuntu with 
python3.7, postgreSQL, nginx installed and configured

## Build docker image

Open a terminal and run this command to pull the image

`docker pull davidezanin/demodocker:v1.0.0`

To create the docker image, docker file should be in this folder:

`sudo docker build -t davidezanin/demodocker:v1.0.0 .`

To create and start the container:

`sudo docker run -d --name demodockerContainer -p 80:80 demodocker:v1.0.0`

To create and start the container using the console (example to try flat project):

`sudo docker run -it --name demodockerContainer -p 8080:80 demodocker:v1.0.0 /bin/sh`

To start after the first run:

`docker start demodockerContainer`

To stop:

`docker stop demodockerContainer`

Inspect:

`docker inspect demodockerContainer`

List running containers:

`docker ps`

List all containers:

`docker ps`

List all images:

`docker images`

Delete containers:

`docker rmi <ContainerID1> <ContainerID2> ...`

Delete images:

`docker rmi <ImageID1> <ImageID2> ...`


