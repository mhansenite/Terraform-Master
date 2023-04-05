variable "master" {}
variable "conf" {}
variable "app" {}
variable "app_name" {}
variable "my_target_group_arn" {}
variable "my_security_group_id" {}


data "aws_vpc" "my_vpc" {
  filter {
  name = "tag:Name"
  values = ["${var.conf.lane}-VPC"]

  }

}

data "aws_subnets" "my_subnets" {
  filter {
    name   = "tag:Name"
    values = [ "${var.conf.lane}-AP-Zone-*-SN" ]

  }
}



//TaskDefinition
resource "aws_ecs_task_definition" "resource_taskdef" {
  lifecycle { ignore_changes = all }
  
  family                = "${var.conf.lane}-${var.app_name}"
  requires_compatibilities = ["FARGATE"]
  cpu = var.app.cpu
  memory = var.app.memory
  task_role_arn = "arn:aws:iam::${var.master.aws_account_id}:role/${var.master.company}-ecsTaskExecutionRole"
  network_mode = "awsvpc"
  execution_role_arn ="arn:aws:iam::${var.master.aws_account_id}:role/${var.master.company}-ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      "name":"${var.conf.lane}-${var.app_name}-docker",
      "image":"${var.app.image_uri}",
      "essential":true,
      
      "environmentFiles" :[
        {
          "value":"${var.conf.env_file_path}/${var.conf.lane}-${var.app_name}.env",
          "type":"s3"
        }
      ],
      
      "portMappings":[
        {
          "containerPort" : "${var.app.internal_port}",
          "hostPort" : "${var.app.external_port}",
          "protocol" : "tcp"
        }
      ],
      
      "logConfiguration":{
        "logDriver":"awslogs",
              "options":{
                  "awslogs-group":"${var.conf.lane}-${var.app_name}",
                  "awslogs-region":"${var.master.region}",
                  "awslogs-stream-prefix":"ecs"
                }
          }
    }
  ])
  ephemeral_storage {
      size_in_gib= "${var.app.storage}"
    }
}

resource "aws_ecs_cluster" "resource_cluster" {
  name = "${var.conf.lane_full}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "resource_service" {
  depends_on = [aws_ecs_task_definition.resource_taskdef]
  lifecycle {
    ignore_changes = all
  }
  cluster = aws_ecs_cluster.resource_cluster.name

  deployment_circuit_breaker {
    enable   = "false"
    rollback = "false"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = var.app.instance_count
  enable_ecs_managed_tags            = "true"
  enable_execute_command             = "false"
  health_check_grace_period_seconds  = "230"
  launch_type                        = "FARGATE"

  load_balancer {
    container_name   = "${var.conf.lane}-${var.app_name}-docker"
    container_port   = var.app.external_port
    target_group_arn = var.my_target_group_arn
  }

  name = "${var.conf.lane}-${var.app_name}-SV"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [var.my_security_group_id]
    subnets          = data.aws_subnets.my_subnets.ids
  }

  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"
  task_definition     = aws_ecs_task_definition.resource_taskdef.arn
  //task_definition     = aws_ecs_task_definition.resource_taskdef.arn
  //task_definition     = var.conf.task_def
}
