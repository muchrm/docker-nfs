#!/bin/sh
docker container rm -f nfs-server
docker container rm -f nginx
docker volume rm -f nfs-volume

docker run -d --name nfs-server \
    --privileged -v $(pwd)/storage:/nfsshare \
    -e SHARED_DIRECTORY=/nfsshare -p 2049:2049 \
    muchrm/nfs-server:alpine3.6

docker volume create --driver local --opt type=nfs \
    --opt o=vers=4,addr=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1| awk '{print $2}'),rw \
    --opt device=:/  nfs-volume

docker run -d --name nginx -v nfs-volume:/usr/share/nginx/html -p 80:80 nginx