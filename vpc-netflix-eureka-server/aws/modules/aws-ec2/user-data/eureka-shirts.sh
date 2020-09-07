#!/bin/bash

# Docker installation

yum install -y docker

systemctl start docker

systemctl enable docker

docker run --name eureka-shirts -p 80:8080 --restart unless-stopped -id quickbooks2018/eureka-shirts:latest


#END