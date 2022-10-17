resource "aws_ecr_repository" "hello-world-images" {
  name = "hello-world-images"
  

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecs_cluster" "hello-world-cluster" {
  name = "hello-world"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.hello-world-cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 4
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "hello-world-api" {
  family                   = "hello-world-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  task_role_arn = aws_iam_role.ecsTaskRole.arn
  execution_role_arn = aws_iam_role.ecsTaskRole.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "hello-world",
    "image": "738921266859.dkr.ecr.us-east-1.amazonaws.com/hello-world-images:latest",
    "cpu": 256,
    "memoryReservation": 128,
    "essential": true,
    "portMappings": [
      {
      "containerPort": 8888
    }
    ]
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "hello-api-service" {
  name            = "hello-api-service"
  cluster         = aws_ecs_cluster.hello-world-cluster.id
  task_definition = aws_ecs_task_definition.hello-world-api.id
  desired_count   = 2

  network_configuration {
    subnets = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
    security_groups = [aws_security_group.allow_traffic_to_service.id] 
    assign_public_ip = true
  }
  load_balancer {
   target_group_arn = aws_lb_target_group.ip-hello-world.arn
    container_name   = "hello-world"
    container_port   = 8888
  }
  deployment_circuit_breaker {
    enable = true
    rollback = true
  }
}