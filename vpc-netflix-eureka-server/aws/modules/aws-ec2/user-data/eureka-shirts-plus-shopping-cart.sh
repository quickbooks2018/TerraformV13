#!/bin/bash

# Docker installation

yum install -y docker

systemctl start docker

systemctl enable docker

docker run --name eureka-shirts -h shirts.cloudgeeks.ca.local -p 8080:8080 --restart unless-stopped -id quickbooks2018/eureka-shirts:latest
docker run --name eureka-shopping-cart -h shopping-cart.cloudgeeks.ca.local  -p 8090:8090 --restart unless-stopped -id quickbooks2018/eureka-shopping-cart:latest

#END