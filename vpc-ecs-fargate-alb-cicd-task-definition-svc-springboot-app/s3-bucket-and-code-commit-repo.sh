#!/bin/bash
# Aurthor: Muhammad Asim <quickbooks2018@gmail.com>
# Puporse: ECS CICD Automation
# Requirements ---> AWS CLI must be installed.

REPOBUCKETNAME="cloudgeeks-quickbooks2018-path-blue"
REGION=""us-east-1


# REPO DESCRIPTION
DESCRIPTION="Custom bucket setup for ECS CICD"

# S3
aws s3api create-bucket --bucket "$REPOBUCKETNAME" --region "$REGION"

# CodeCommit

aws codecommit create-repository --repository-name "$REPOBUCKETNAME" --repository-description "$DESCRIPTION"








# END