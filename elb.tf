### Creating an Image ###
resource "aws_ami_from_instance" "wp_ubuntu_ami" {
  name               = "ubuntu_wordpress_ami"
  source_instance_id = aws_instance.wp_ubuntu.id

  depends_on = [
    aws_instance.wp_ubuntu,
  ]

  tags = {
    Name = "ubuntu_wordpress_ami"
  }

}

### Creating Launch Configuration for AutoScaling  ###

resource "aws_launch_configuration" "launch-config" {
  name_prefix   = "launch-config"
  image_id      = aws_ami_from_instance.wp_ubuntu_ami.id
  instance_type = "t2.micro"
  root_block_device {
    delete_on_termination = false
    encrypted             = true
  }

}



### Creating AutoScaling Group ###

resource "aws_autoscaling_group" "autoscaling-grp" {
  name                      = "autoscaling-grp"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.launch-config.name
  vpc_zone_identifier       = [aws_subnet.subnet3.id, aws_subnet.subnet4.id]
}


### Creating Load Balancer Target Group ###

resource "aws_lb_target_group" "trg-wordpress" {
  name     = "trg-wordpress"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    interval            = 10
    matcher             = 200
  }

}

### Attaching the target group ###

resource "aws_lb_target_group_attachment" "trg-attachment" {
  target_group_arn = aws_lb_target_group.trg-wordpress.arn
  target_id        = aws_instance.wp_ubuntu.id
  port             = 80
}


### Creating the Load Balancer ###

resource "aws_lb" "lb-wordpress" {
  name               = "lb-wordpress"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.for_public.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = true
}

### Listener ###

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb-wordpress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.trg-wordpress.arn
  }
}

