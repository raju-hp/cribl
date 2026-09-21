data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official Ubuntu AMI owner

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_launch_template" "worker_lt" {
  name_prefix   = "${var.name}-lt"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile
  }

  user_data = base64encode(
    templatefile("${path.module}/scripts/worker-userdata.sh", {
      CRIBL_LEADER_IP   = var.leader_leader_ip,
      CRIBL_DIR         = var.cribl_dir,
      CRIBL_WORKER_PORT = var.cribl_worker_port,
      CRIBL_LOG_FILE    = var.cribl_log_file
      CRIBL_DIST_TOKEN  = var.cribl_dist_token
    })
  )

  vpc_security_group_ids = var.security_groups

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.name}-worker"
        Role = "cribl-worker"
      }
    )
  }
}

resource "aws_autoscaling_group" "worker_asg" {
  name_prefix         = "${var.name}-asg"
  desired_capacity    = var.desired_count
  min_size            = var.worker_min_max[0]
  max_size            = var.worker_min_max[1]
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.worker_lt.id
    version = "$Latest"
  }

  target_group_arns = [var.alb_target_group_arn]

  tag {
    key                 = "Name"
    value               = "${var.name}-worker"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
