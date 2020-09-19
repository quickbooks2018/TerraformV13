#########
# Labels
########

module "label" {
  source     = "../terraform-label"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags

}



resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = module.label.name


  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }


  setting {
    name = "containerInsights"
    value = var.container-insights
  }
}
