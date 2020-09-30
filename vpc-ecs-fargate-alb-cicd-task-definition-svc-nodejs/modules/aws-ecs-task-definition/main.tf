resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.ecs_task_definition_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task-definition-cpu
  memory                   = var.task-definition-memory
  container_definitions    = var.container-definitions
  execution_role_arn       = aws_iam_role.ecs-task-execution-role.arn
}

# ECS Task Execution Policy

resource "aws_iam_policy" "ecs-task-execution-policy" {
  name = "ecs-task-execution-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# IAM Role Task Execution Role

resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs-task-execution-policy-attach" {
  name           = "ecs-task-execution-policy-attach"
  roles          = [aws_iam_role.ecs-task-execution-role.name]
  policy_arn     = aws_iam_policy.ecs-task-execution-policy.arn
}

resource "aws_cloudwatch_log_group" "aws-cloudwatch-log-group" {
  name = var.cloudwatch-group

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}