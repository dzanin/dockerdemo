# dockerdemo

In this repository you can find a demo to create a docker based on ubuntu with 
python3.7, postgreSQL, nginx installed


## Build docker image and run

Open a terminal and run this command to pull the image

`docker pull davidezanin/demodocker:vx.x.x`

To create the docker image, docker file should be in this folder, 
use release version instead of x.x.x (e.g. RELEASE=7.1.5):

`docker build --build-arg RELEASE=x.x.x -t davidezanin/demodocker:vx.x.x . `

To create and start the container:

`sudo docker run -d --name demodockerContainer -p 80:80 davidezanin/demodocker:vx.x.x`

To create and start the container using the console (example to try flat project):

`sudo docker run -it --name demodockerContainer -p 80:80 davidezanin/demodocker:vx.x.x /bin/sh`

To start after the first run:

`docker start demodockerContainer`

To stop:

`docker stop demodockerContainer`

Inspect:

`docker inspect demodockerContainer`


## List containers/images

List running containers:

`docker ps`

List all containers:

`docker ps -a`

List all images:

`docker images`


## Delete Containers/images

Delete containers:

`docker rmi <ContainerID1> <ContainerID2> ...`

Delete images:

`docker rmi <ImageID1> <ImageID2> ...`

Delete all images:

`docker rmi $(docker images -q)`

Delete all containers:

`docker rm $(docker ps -a -q)`

Delete dangling images:

`docker rmi -f $(docker images -f "dangling=true" -q)`

##Push on dockerhub

Push images on dockerhub (tagged during build):

`docker login`
`docker push davidezanin/demodocker`


