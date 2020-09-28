#!/bin/bash
# Purpose: Creations of Secrets for ECS Environment Variables
# Maintainer: Muhammad Asim <quickbooks2018@gmail.com>
# Prerequisites: AWS CLI Installed with admin privileges/Git Bash/jq

# USER #
USER_ID="user"
USER_SECRET="asim"

# PASSWORD #
PASSWORD_ID="password"
PASSWORD_SECRET="12345678"


# RDS END POINT
RDS_END_POINT_ID="urls"
RDS_END_POINT_ID_SECRET="jdbc:mysql://springboot-db.c4gvraiulxqm.us-east-1.rds.amazonaws.com:3306/springbootdb"


# user
############################################################################################################
aws secretsmanager create-secret --name "$USER_ID" --description "DB USER NAME" --secret-string "$USER_SECRET"
user=`aws secretsmanager get-secret-value --secret-id "$USER" --region us-east-1 | jq .SecretString`
dbuser=`echo $user`
############################################################################################################
user_arn=`aws secretsmanager describe-secret --secret-id user | jq .ARN`
echo $user_arn
export user_arn


# password
##################################################################################################################
aws secretsmanager create-secret --name "$PASSWORD_ID" --description "DB PASSWORD" --secret-string "$PASSWORD_SECRET"
password=`aws secretsmanager get-secret-value --secret-id "$PASSWORD_ID" --region us-east-1 | jq .SecretString`
dbpassword=`echo $password`
###################################################################################################################
password_arn=`aws secretsmanager describe-secret --secret-id password | jq .ARN`
echo $password_arn
export password_arn


# url
############################################################################################################################################################################
aws rds describe-db-instances --db-instance-identifier springboot-db | grep -i -A 4 endpoint
aws secretsmanager create-secret --name "$RDS_END_POINT_ID" --description "RDS END POINT" --secret-string "$RDS_END_POINT_ID_SECRET"
url=`aws secretsmanager get-secret-value --secret-id "$RDS_END_POINT_ID" --region us-east-1 | jq .SecretString`
rdsendpoint=`echo $url`
url_arn=`aws secretsmanager describe-secret --secret-id url | jq .ARN`
echo $url
export user_arn


# Update Existing Secret
# Update Existing Secrets

# aws secretsmanager update-secret --secret-id url --description "This is a new description for the secret." --secret-string "jdbc:mysql://springboot-db.ce9hcrwrmpdb.us-east-1.rds.amazonaws.com:3306/springbootdb"

# END