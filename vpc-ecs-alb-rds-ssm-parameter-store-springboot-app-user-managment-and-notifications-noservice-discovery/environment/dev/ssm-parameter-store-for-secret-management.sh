#!/bin/bash
#Purpose: Secrets Management for ECS Service from SSM Parameter Store

# AWS_RDS_HOSTNAME
aws rds describe-db-instances --db-instance-identifier springboot-db | grep -i -A 4 endpoint


aws ssm put-parameter --name RDS_HOSTNAME --value "springboot-db.cm2z8nvmnemh.us-east-1.rds.amazonaws.com" --type SecureString --overwrite
aws ssm get-parameters --names RDS_HOSTNAME | grep -i arn


# AWS_RDS_DB_NAME
aws ssm put-parameter --name RDS_DB_NAME --value "springbootdb" --type SecureString --overwrite
aws ssm get-parameters --names RDS_DB_NAME | grep -i arn

# AWS_RDS_USERNAME
aws ssm put-parameter --name RDS_USERNAME --value "asim" --type SecureString --overwrite
aws ssm get-parameters --names RDS_USERNAME | grep -i arn

# AWS_RDS_DB_PASSWORD
aws ssm put-parameter --name RDS_DB_PASSWORD --value "12345678" --type SecureString --overwrite
aws ssm get-parameters --names RDS_DB_PASSWORD | grep -i arn

## NOTIFICATION_SERVICE_HOST
## ALB END POINT
#aws ssm put-parameter --name NOTIFICATION_SERVICE_HOST --value "cloudgeeks-alb-368248622.us-east-1.elb.amazonaws.com" --type SecureString --overwrite
#aws ssm get-parameters --names NOTIFICATION_SERVICE_HOST | grep -i arn













## AWS Parameter Store
#
#---> https://docs.aws.amazon.com/cli/latest/reference/ssm/put-parameter.html
#
#---> https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-securestring.html
#
#Example 1: To change a parameter value
#
#The following put-parameter example changes the value of the specified parameter.
#
## Secure
#
#aws ssm put-parameter \
#    --name parameter-name \
#    --value "parameter-value" \
#    --type SecureString
#
# aws ssm put-parameter \
#    --name "dbpassword" \
#    --value "12345678" \
#    --type SecureString \
#    --overwrite
#
#
## Unsecure
#
#aws ssm put-parameter \
#    --name "dbpassword" \
#    --type "String" \
#    --value "123456789999" \
#    --overwrite
#
#aws ssm get-parameters --names "dbpassword"
#
#SSM-Parameter
#arn:aws:ssm:us-east-1:427318149626:parameter/dbpassword







# END