#!/usr/bin/env bash
sudo docker rm -f $(sudo docker ps -a -q)
image_id=$(sudo docker images | grep sierra/nifi | awk '{ print $3 }')
sudo docker rmi -f $image_id
sudo docker build -t sierra/nifi:1.11.3 ../
sudo docker run -p 389:389 -p 636:636 --name ldap --hostname ldap --net mynet -d osixia/openldap
sudo docker run -p 2181:2181 --name zookeeper --hostname zookeeper -e ALLOW_ANONYMOUS_LOGIN=yes --net mynet -d bitnami/zookeeper