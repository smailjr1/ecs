resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.project_name
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.project_name}-log-group"
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"

  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_launch_configuration" "ecs_launch_configuration" {
  name = var.project_name

  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  image_id = var.ecs_instance_ami_id
  instance_type = var.ecs_instance_type
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  desired_capacity     = var.desired_count
  max_size             = var.max_count
  min_size             = var.min_count
  launch_configuration = aws_launch_configuration.ecs_launch_configuration.id

  vpc_zone_identifier = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = var.project_name
  container_definitions = <<DEFINITION
[{
    "name": "site",
    "image": "${var.ecr_image}",
    "cpu": 0,
    "essential": true,
    "networkMode": "awsvpc",
    "portMappings": [
        {
            "containerPort": 80,
            "hostPort": 80,
            "protocol": "tcp"
        }
    ],
    "privileged": false,
    "readonlyRootFilesystem": false,
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "site"
        }
    }
}]
DEFINITION

  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]  # Use EC2 instead of FARGATE
  cpu                      = 256
  memory                   = 512
}

resource "aws_ecs_service" "ecs_service" {
  name                = var.project_name
  cluster             = aws_ecs_cluster.ecs_cluster.id
  task_definition     = aws_ecs_task_definition.task_definition.arn
  launch_type         = "EC2"  # Use EC2 instead of FARGATE
  desired_count       = var.desired_count

  scheduling_strategy = "REPLICA"

  network_configuration {
    subnets          = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
    security_groups  = [aws_security_group.ecs_tasks.id, aws_security_group.alb.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    container_name   = "site"
    container_port   = 80
  }

  depends_on = [aws_alb_listener.alb_listener]
}
