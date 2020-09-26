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
  publicly-accessible                                              = "true"
  rds-username                                                     = var.rds-username
  rds-password                                                     = var.rds-password
  multi-az                                                         = "true"
  storage-encrypted                                                = "false"
  deletion-protection                                              = "false"
  vpc-security-group-ids                                           = [module.sg1.aws_security_group_default]
  subnet_ids                                                       = module.vpc.public-subnet-ids
}



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
  tcp_ports               = "80,443,8080"
  ref_security_groups_ids = [module.alb-sg.aws_security_group_default,module.alb-sg.aws_security_group_default,module.alb-sg.aws_security_group_default]
  security_group_name     = "ALB-Ref"
  vpc_id                  = module.vpc.vpc-id
}

module "alb-tg" {
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


module "alb" {
  source = "../../modules/aws-alb"
  alb-name                   = "cloudgeeks-alb"
  internal                   = "false"
  alb-sg                     = module.alb-sg.aws_security_group_default
  alb-subnets                = module.vpc.public-subnet-ids
  alb-tag                    = "cloudgeeks-alb"
  enable-deletion-protection = "false"
  target-group-arn           = module.service-alb-tg.target-group-arn
  # ALB Rules
  rule-path                  = "/products"

}


module "ecs" {
  source                    = "../../modules/aws-ecs"
  name                      = "cloudgeeks-ecs-dev"
  container-insights        = "enabled"
  depends_on                = [module.alb]
}


module "aws-ecs-task-definition" {
  source                       = "../../modules/aws-ecs-task-definition"
  ecs_task_definition_name     = var.task-definition-name
  task-definition-cpu          = var.task-definition-cpu
  task-definition-memory       = var.task-definition-memory
  cloudwatch-group             = var.cloudwatch-group
  container-definitions        = <<DEFINITION
  [
      {
        "name": "${var.container-name}",
        "image": "${var.repository-uri}",
        "essential": true,
        "portMappings": [
          {
            "containerPort": ${var.fargate-container-port},
            "hostPort": ${var.fargate-container-port}
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${var.cloudwatch-group}",
            "awslogs-region": "${var.aws-region}",
            "awslogs-stream-prefix": "${var.log-stream-prefix}"
          }
        }
      }
    ]
DEFINITION

}

module "service-alb-tg" {
  source = "../../modules/aws-alb-tg-type-ip"
  #Application Load Balancer Target Group
  alb-tg-name               = "ecs-spring-boot"
  target-group-port         = "80"
  target-group-protocol     = "HTTP"
  target-type               = "ip"
  deregistration_delay      = "1"
  vpc-id                    = module.vpc.vpc-id
  # Health
  health-check              = true
  interval                  = "5"
  path                      = "/products"
  port                      = "8080"
  protocol                  = "HTTP"
  timeout                   = "3"
  unhealthy-threshold       = "3"
  matcher                   = "200,202"

}

module "aws-ecs-service" {
  source = "../../modules/aws-ecs-service"
  aws-ecscluster-name                 = module.ecs.aws-ecs-cluster-name
  aws-ecs-service-name                = "blue"
  ecs-cluster-id                      = module.ecs.aws-ecs-cluster-id
  deployment-minimum-healthy-percent  = "100"
  deployment-maximum-percent          = "200"
  security-groups                     = [module.alb-ref.aws_security_group_default]
  private-subnets                     = module.vpc.private-subnet-ids
  assign-public-ip                    = "false"
  task-definition                     = module.aws-ecs-task-definition.ecs-taks-definitions-arn
  # Auto Scaling of Tasks
  min-capacity                        = 2
  max-capacity                        = 5
  desired-count                       = 2
  # CPU-Exceeds-Percentage
  cpu-exceeds-percentage              = 80
  # Memory-Exceeds-Percentage
  memory-exceeds-percentage           = 90
  health-check-grace-period-seconds   = "180"
  target-group-arn                    = module.service-alb-tg.target-group-arn
  container-name                      = var.container-name
  container-port                      = var.fargate-container-port
  depends_on                          = [module.alb]
}

