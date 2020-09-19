provider "aws" {
  region = "us-east-1"
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


module "sg1" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "ecs"
  tcp_ports           = "22,80,443"
  cidrs               = ["111.119.187.1/32"]
  security_group_name = "ecs"
  vpc_id              = module.vpc.vpc-id
}

module "sg2" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "rds"
  tcp_ports               = "3306"
  ref_security_groups_ids = [module.sg1.aws_security_group_default]
  security_group_name     = "rds"
  vpc_id                  = module.vpc.vpc-id
}



module "apachebench-eip" {
  source = "../../modules/aws-eip/ecs"
  name                         = "apachebench"
  instance                     = module.ec2-apachebench.id[0]
}

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

module "alb-ref" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "ALB-Ref"
  tcp_ports               = "80,443"
  ref_security_groups_ids = [module.alb-sg.aws_security_group_default,module.alb-sg.aws_security_group_default]
  security_group_name     = "ALB-Ref"
  vpc_id                  = module.vpc.vpc-id
}

module "alb-tg" {
  source = "../../modules/aws-alb-tg"
  #Application Load Balancer Target Group
  alb-tg-name               = "cloudgeeks-tg"
  target-group-port         = "80"
  target-group-protocol     = "HTTP"
  vpc-id                    = module.vpc.vpc-id
}


module "alb" {
  source = "../../modules/aws-alb"
  alb-name                 = "cloudgeeks-alb"
  internal                 = "false"
  alb-sg                   = module.alb-sg.aws_security_group_default
  alb-subnets              = module.vpc.public-subnet-ids
  alb-tag                  = "cloudgeeks-alb"
  target-group-arn         = module.alb-tg.target-group-arn
}


module "ecs" {
  source                    = "../../modules/aws-ecs"
  name                      = "cloudgeeks-ecs-dev"
  container-insights        = "enabled"
}


module "aws-ecs-task-definition" {
  source                       = "../../modules/aws-ecs-task-definition"
  ecs_task_definition_name     = "islam"
  task-definition-cpu          = 2048
  task-definition-memory       = 4096
  cloudwatch-group             = var.cloudwatch-group
  container-definitions        = <<DEFINITION
  [
      {
        "name": "${var.container-name}",
        "image": "${var.repository-uri}",
        "essential": true,
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${var.cloudwatch-group}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "quickbooks2018"
          }
        }
      }
    ]
DEFINITION

}
