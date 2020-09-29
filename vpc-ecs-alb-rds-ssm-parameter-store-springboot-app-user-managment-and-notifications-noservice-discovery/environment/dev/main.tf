provider "aws" {
  region = "us-east-1"
 # version = "~> 3.7.0"
}


#####
# Vpc
#####

module "vpc" {
  source = "../../modules/aws-vpc"

  vpc-location                        = "Virginia"
  namespace                           = "cloudgeeks.ca"
  name                                = "vpc"
  stage                               = "ecs-dev"
  map_public_ip_on_launch             = "true"
  total-nat-gateway-required          = "1"
  create_database_subnet_group        = "true"
  vpc-cidr                            = "10.20.0.0/16"
  vpc-public-subnet-cidr              = ["10.20.1.0/24","10.20.2.0/24"]
  vpc-private-subnet-cidr             = ["10.20.4.0/24","10.20.5.0/24"]
  vpc-database_subnets-cidr           = ["10.20.7.0/24", "10.20.8.0/24"]
}

# RDS mysql

module "rds-mysql" {
  source                                                           = "../../modules/aws-rds-mysql"
  namespace                                                        = "cloudgeeks.ca"
  stage                                                            = "dev"
  name                                                             = "springboot-db"
  rds-name                                                         = "springboot-db"
  database-name                                                    = "springbootdb"
  final-snapshot-identifier                                        = "cloudgeeks-ca-db-final-snap-shot"
  skip-final-snapshot                                              = "true"
  rds-allocated-storage                                            = "5"
  storage-type                                                     = "gp2"
  rds-engine                                                       = "mysql"
  engine-version                                                   = "5.7.17"
  db-instance-class                                                = "db.t2.micro"
  backup-retension-period                                          = "0"
  backup-window                                                    = "04:00-06:00"
  publicly-accessible                                              = "false"
  rds-username                                                     = var.rds-username
  rds-password                                                     = var.rds-password
  multi-az                                                         = "true"
  storage-encrypted                                                = "false"
  deletion-protection                                              = "false"
  vpc-security-group-ids                                           = [module.rds-sg.aws_security_group_default]
  subnet_ids                                                       = module.vpc.private-subnet-ids
}


# Security Group

module "sg1" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "ecs"
  tcp_ports           = "22,80,443,3306"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "ecs"
  vpc_id              = module.vpc.vpc-id
}

# RDS Security Group ---> allowed aws-ecs-service-user-management

module "rds-sg" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "rds"
  tcp_ports               = "3306"
  ref_security_groups_ids = [module.alb-ref.aws_security_group_default]
  security_group_name     = "rds"
  vpc_id                  = module.vpc.vpc-id
}




# Elastic IP for EC2---> ECS Service Load Testing for ECS ---> endpoint(alb)

module "apachebench-eip" {
  source = "../../modules/aws-eip/ecs"
  name                         = "apachebench"
  instance                     = module.ec2-apachebench.id[0]
}

# ECS Service Load Testing for ECS ---> endpoint(alb)

module "ec2-apachebench" {
  source                        = "../../modules/aws-ec2"
  namespace                     = "cloudgeeks.ca"
  stage                         = "dev"
  name                          = "apachebench"
  key_name                      = "ecs"
  public_key                    = file("../../modules/secrets/ecs.pub")
  user_data                     = file("../../modules/aws-ec2/user-data/user-data.sh")
  instance_count                = 1
  ami                           = "ami-00eb20669e0990cb4"
  instance_type                 = "t3a.medium"
  associate_public_ip_address   = "true"
  root_volume_size              = 10
  subnet_ids                    = module.vpc.public-subnet-ids
  vpc_security_group_ids        = [module.sg1.aws_security_group_default]

}



# ALB Security Group

module "alb-sg" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "ALB"
  tcp_ports           = "80,443"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "Application-LoadBalancer"
  vpc_id              = module.vpc.vpc-id
}

# ALB Security Group used as a referenced in ---> ECS ---> module "aws-ecs-service-user-management

module "alb-ref" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "ALB-Ref"
  tcp_ports               = "8095,8096"
  ref_security_groups_ids = [module.alb-sg.aws_security_group_default,module.alb-sg.aws_security_group_default,module.alb-sg.aws_security_group_default]
  security_group_name     = "ALB-Ref"
  vpc_id                  = module.vpc.vpc-id
}


# ALB Default TG

module "alb-default-tg" {
  source = "../../modules/aws-alb-tg-type-instance"
  #Application Load Balancer Target Group
  alb-tg-name               = "cloudgeeks-tg"
  target-group-port         = "80"
  target-group-protocol     = "HTTP"
  vpc-id                    = module.vpc.vpc-id
  # Health
  health-check             = true
  interval                 = "5"
  path                     = "/"
  port                     = "80"
  protocol                 = "HTTP"
  timeout                  = "3"
  unhealthy-threshold      = "3"
  matcher                  = "200,202"


}

# ALB Application Load Balancer

module "alb" {
  source = "../../modules/aws-alb"
  alb-name                            = "cloudgeeks-alb"
  internal                            = "false"
  alb-sg                              = module.alb-sg.aws_security_group_default
  alb-subnets                         = module.vpc.public-subnet-ids
  alb-tag                             = "cloudgeeks-alb"
  enable-deletion-protection          = "false"
  target-group-arn                    = module.alb-default-tg.target-group-arn
  # ALB Default Rules
  rule-default-path                   = "/"
  # Custom Rules & Tg
  user-management-target-group-arn    = module.service-user-management-alb-tg.target-group-arn
  user-management-path                = "/usermgmt/*"

}

# ECS Fargate Cluster
module "ecs" {
  source                    = "../../modules/aws-ecs"
  name                      = "cloudgeeks-ecs-dev"
  container-insights        = "enabled"
  depends_on                = [module.alb]
}

# ECS Task Definition for ---> task-definition-user-management

module "aws-ecs-task-definition-user-management" {
  source                       = "../../modules/aws-ecs-task-definition"
  ecs_task_definition_name     = var.task-definition-name-user-management-service
  task-definition-cpu          = var.task-definition-cpu
  task-definition-memory       = var.task-definition-memory
  cloudwatch-group             = var.cloudwatch-group
  container-definitions        = <<DEFINITION
  [
      {
        "name": "${var.microservice-user-management-container-name}",
        "image": "${var.microservice-user-management-repository-uri}",
        "essential": true,
        "portMappings": [
          {
            "containerPort": ${var.microservice-user-management-fargate-container-port},
            "hostPort": ${var.microservice-user-management-fargate-container-port}
          }
        ],
        "secrets": [
                {
                    "name": "AWS_RDS_HOSTNAME",
                    "valueFrom": "arn:aws:ssm:us-east-1:444389401196:parameter/RDS_HOSTNAME"
                },
                 {
                      "name": "AWS_RDS_DB_NAME",
                     "valueFrom": "arn:aws:ssm:us-east-1:444389401196:parameter/RDS_DB_NAME"
                  },
                  {
                      "name": "AWS_RDS_USERNAME",
                     "valueFrom": "arn:aws:ssm:us-east-1:444389401196:parameter/RDS_USERNAME"
                  },
                  {
                      "name": "AWS_RDS_PASSWORD",
                     "valueFrom": "arn:aws:ssm:us-east-1:444389401196:parameter/RDS_DB_PASSWORD"
                  }
            ],
                "environment": [
                {
                    "name": "AWS_RDS_PORT",
                    "value": "3306"
                },
                {
                      "name": "NOTIFICATION_SERVICE_PORT",
                     "value": "80"
                  }
            ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${var.cloudwatch-group}",
            "awslogs-region": "${var.aws-region}",
            "awslogs-stream-prefix": "${var.user-management-container-log-stream-prefix}"
          }
        }
      }
    ]
DEFINITION

}


# ALB Custom Target Group ---> ECS-->Service--> svc-user-management

module "service-user-management-alb-tg" {
  source = "../../modules/aws-alb-tg-type-ip"
  #Application Load Balancer Target Group
  alb-tg-name               = "tg-user-management"
  target-group-port         = "80"
  target-group-protocol     = "HTTP"
  target-type               = "ip"
  deregistration_delay      = "1"
  vpc-id                    = module.vpc.vpc-id
  # Health
  health-check              = true
  interval                  = "5"
  path                      = "/usermgmt/health-status"
  port                      = "8095"
  protocol                  = "HTTP"
  timeout                   = "3"
  unhealthy-threshold       = "3"
  matcher                   = "200,202"

}

# ECS Service Setup ---> svc-user-management

module "aws-ecs-service-user-management" {
  source = "../../modules/aws-ecs-service"
  aws-ecscluster-name                 = module.ecs.aws-ecs-cluster-name
  aws-ecs-service-name                = "svc-user-management"
  ecs-cluster-id                      = module.ecs.aws-ecs-cluster-id
  deployment-minimum-healthy-percent  = "100"
  deployment-maximum-percent          = "200"
  security-groups                     = [module.alb-ref.aws_security_group_default]
  private-subnets                     = module.vpc.private-subnet-ids
  assign-public-ip                    = "false"
  task-definition                     = module.aws-ecs-task-definition-user-management.ecs-task-definitions-arn
  # Auto Scaling of Tasks
  min-capacity                        = 2
  max-capacity                        = 5
  desired-count                       = 2
  # CPU-Exceeds-Percentage
  cpu-exceeds-percentage              = 80
  # Memory-Exceeds-Percentage
  memory-exceeds-percentage           = 90
  health-check-grace-period-seconds   = "180"
  target-group-arn                    = module.service-user-management-alb-tg.target-group-arn
  container-name                      = var.microservice-user-management-container-name
  container-port                      = var.microservice-user-management-fargate-container-port
  depends_on                          = [module.alb]
}

//module "user-managment-service-secrets-creation" {
//  source = "../../modules/terraform-local-exec-provisioners"
//  command       = "bash secrets-environment-variables.sh > secrets-environment-variables-output && cat secrets-environment-variables-output"
//  depends_on    = [module.aws-ecs-microservice-user-management]
//}

### AWS SES SMTP ###

module "smtp-ses" {
  source = "../../modules/aws-ses"
  email-verification                        = "quickbooks2018@gmail.com"
  user_name                                 = "smtp-user"

}


# ECS Task Definition for ---> task-definition-notification-service

module "aws-ecs-task-definition-notification-service" {
  source                       = "../../modules/aws-ecs-task-definition"
  ecs_task_definition_name     = var.task-definition-name-notification-service
  task-definition-cpu          = var.task-definition-cpu
  task-definition-memory       = var.task-definition-memory
  cloudwatch-group             = var.cloudwatch-group
  container-definitions        = <<DEFINITION
  [
      {
        "name": "${var.microservice-user-management-container-name}",
        "image": "${var.microservice-user-management-repository-uri}",
        "essential": true,
        "portMappings": [
          {
            "containerPort": ${var.microservice-user-management-fargate-container-port},
            "hostPort": ${var.microservice-user-management-fargate-container-port}
          }
        ],
        "secrets": [
                {
                    "name": "AWS_RDS_HOSTNAME",
                    "valueFrom": "arn:aws:ssm:us-east-1:444389401196:parameter/RDS_HOSTNAME"
                },
                 {
                      "name": "AWS_RDS_DB_NAME",
                     "valueFrom": "arn:aws:ssm:us-east-1:444389401196:parameter/RDS_DB_NAME"
                  },
                  {
                      "name": "AWS_RDS_USERNAME",
                     "valueFrom": "arn:aws:ssm:us-east-1:444389401196:parameter/RDS_USERNAME"
                  },
                  {
                      "name": "AWS_RDS_PASSWORD",
                     "valueFrom": "arn:aws:ssm:us-east-1:444389401196:parameter/RDS_DB_PASSWORD"
                  }
            ],
                "environment": [
                {
                    "name": "AWS_RDS_PORT",
                    "value": "3306"
                },
                {
                      "name": "NOTIFICATION_SERVICE_PORT",
                     "value": "80"
                  }
            ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${var.cloudwatch-group}",
            "awslogs-region": "${var.aws-region}",
            "awslogs-stream-prefix": "${var.user-management-container-log-stream-prefix}"
          }
        }
      }
    ]
DEFINITION

}

