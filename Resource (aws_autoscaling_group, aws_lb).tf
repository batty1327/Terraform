# Define the provider block to specify AWS region (AWS access and secret keys are not recommended to be hardcoded here)
provider "aws" {
  region = "ap-south-1"  # AWS region
  access_key = "**********************"          # Your AWS access key (replace with your own)
  secret_key = "**********************"          # Your AWS secret key (replace with your own)
}

# Define data sources to fetch VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Define the variable for the server port
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

# Define the security group for instances
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  # Ingress rule to allow HTTP traffic
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule to allow SSH traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the launch configuration for Auto Scaling
resource "aws_launch_configuration" "example" {
  image_id        = "ami-0d4a95b1465752c8c"   # Replace with your AMI ID
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  # User data script to execute on instance launch
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p ${var.server_port} &
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Define the Application Load Balancer (ALB)
resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = ["subnet-05a405a812247db6e","subnet-0fb711bb0db5adf11"] # Replace with your subnet IDs
  security_groups    = [aws_security_group.alb.id]
}

# Define the ALB listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # Default action to return a simple 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# Define the ALB security group
resource "aws_security_group" "alb" {
  name = "terraform-example-alb"

  # Ingress rule to allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the ALB target group
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Define the Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.asg.arn]
  health_check_type    = "ELB"
  min_size             = 2
  max_size             = 10

  # Tags for the Auto Scaling Group instances
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

# Define a rule for the ALB listener
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

# Output the DNS name of the ALB
output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

-- Provider Block: Specifies the AWS provider with the region and AWS access and secret keys.

-- Variable Declarations: Define input variables like server_port for the port the server will use.

-- Security Group for Instances (aws_security_group): Defines a security group with ingress and egress rules to control traffic to instances.

-- Launch Configuration (aws_launch_configuration): Configures the launch configuration for instances, including the user data script.

-- Auto Scaling Group (aws_autoscaling_group): Defines an Auto Scaling Group that uses the launch configuration. It also specifies the minimum and maximum instances and tags.

-- Data Sources (data.aws_vpc and data.aws_subnets): Fetches VPC and subnet information.

-- Application Load Balancer (aws_lb): Configures an Application Load Balancer with security groups and subnets.

-- ALB Listener (aws_lb_listener): Sets up an ALB listener on port 80 with a default response.

-- ALB Security Group (aws_security_group): Defines a security group for the ALB with ingress and egress rules.

-- ALB Target Group (aws_lb_target_group): Configures the target group for the ALB.

-- ALB Listener Rule (aws_lb_listener_rule): Defines a rule for the ALB listener.

-- Output (output): Exports the DNS name of the ALB as an output.