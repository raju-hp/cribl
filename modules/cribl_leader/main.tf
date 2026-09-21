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


resource "aws_instance" "leader" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = element(var.subnet_ids, 0)
  iam_instance_profile   = var.instance_profile
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups


  user_data = base64encode(
    templatefile("${path.module}/scripts/leader-userdata.sh", {
      CRIBL_DIR         = var.cribl_dir,
      CRIBL_WORKER_PORT = var.cribl_worker_port,
      CRIBL_LOG_FILE    = var.cribl_log_file
      CRIBL_DIST_TOKEN  = var.cribl_dist_token
    })
  )

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-leader"
      Role = "cribl-leader"
    }
  )
}
