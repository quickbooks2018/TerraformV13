provider "aws" {
  region = "us-east-1"
}

#####
# Vpc
#####

module "vpc" {
  source = "../../modules/aws-vpc"

  vpc-location                 = "Virginia"
  namespace                    = "cloudgeeks.ca"
  name                         = "vpc"
  stage                        = "ec2-dev"
  map_public_ip_on_launch      = "true"
  total-nat-gateway-required   = "1"
  create_database_subnet_group = "false"
  vpc-cidr                     = "20.20.0.0/16"
  vpc-public-subnet-cidr       = ["20.20.1.0/24", "20.20.2.0/24", "20.20.3.0/24", "20.20.4.0/24", "20.20.5.0/24", "20.20.6.0/24"]
  vpc-private-subnet-cidr      = ["20.20.11.0/24", "20.20.12.0/24", "20.20.13.0/24", "20.20.14.0/24", "20.20.15.0/24", "20.20.16.0/24"]
  vpc-database_subnets-cidr    = ["20.20.21.0/24", "20.20.22.0/24", "20.20.23.0/24", "20.20.24.0/24", "20.20.25.0/24", "20.20.26.0./24"]
}


module "sg1" {
  source              = "../../modules/aws-sg-cidr"
  namespace           = "cloudgeeks.ca"
  stage               = "dev"
  name                = "custom"
  tcp_ports           = "80,443"
  cidrs               = ["0.0.0.0/0"]
  security_group_name = "custom"
  vpc_id              = module.vpc.vpc-id
}

module "sg2" {
  source                  = "../../modules/aws-sg-ref-v2"
  namespace               = "cloudgeeks.ca"
  stage                   = "dev"
  name                    = "custom-ref"
  tcp_ports               = "22,80,443"
  ref_security_groups_ids = [module.sg1.aws_security_group_default, module.sg1.aws_security_group_default, module.sg1.aws_security_group_default]
  security_group_name     = "custom-ref"
  vpc_id                  = module.vpc.vpc-id
}

module "nacl" {
  source     = "../../modules/aws-nacl"
  name       = "cloudgeeks-public-nacl"
  subnet-ids = module.vpc.public-subnet-ids
  vpc_id     = module.vpc.vpc-id
}

module "nacl-private-subnets" {
  source     = "../../modules/aws-nacl"
  name       = "cloudgeeks-private-nacl"
  subnet-ids = module.vpc.private-subnet-ids
  vpc_id     = module.vpc.vpc-id
}




