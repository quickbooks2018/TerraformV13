#!/bin/bash

# Docker installation

yum install -y docker

systemctl start docker

systemctl enable docker

docker run --name eureka-shopping-cart -h shopping-cart.cloudgeeks.ca.local  -p 8090:8090 --restart unless-stopped -id quickbooks2018/eureka-shopping-cart:latest


#END