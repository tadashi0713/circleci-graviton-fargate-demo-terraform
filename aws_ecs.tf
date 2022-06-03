resource "aws_ecs_task_definition" "task" {
  family                   = "tadashi-fargate-graviton-demo-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions.json")
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "tadashi-fargate-graviton-demo-cluster"
}

resource "aws_ecs_service" "service" {
  name                              = "tadashi-fargate-graviton-demo-service"
  cluster                           = aws_ecs_cluster.cluster.arn
  task_definition                   = aws_ecs_task_definition.task.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.service.id]
    subnets = module.vpc.public_subnets
  }

  # lifecycle {
  #   ignore_changes = [task_definition]
  # }
}
