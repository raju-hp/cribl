data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Leader Role & Instance Profile
resource "aws_iam_role" "leader_role" {
  name               = "${var.project}-cribl-leader-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "leader_profile" {
  name = "${var.project}-cribl-leader-profile"
  role = aws_iam_role.leader_role.name
  tags = var.tags
}

# Worker Role & Instance Profile
resource "aws_iam_role" "worker_role" {
  name               = "${var.project}-cribl-worker-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "${var.project}-cribl-worker-profile"
  role = aws_iam_role.worker_role.name
  tags = var.tags
}

# Attach AWS Managed Policies
resource "aws_iam_role_policy_attachment" "leader_ssm" {
  role       = aws_iam_role.leader_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "worker_ssm" {
  role       = aws_iam_role.worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "leader_logs" {
  role       = aws_iam_role.leader_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "worker_logs" {
  role       = aws_iam_role.worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Optional S3 Access Policy
data "aws_iam_policy_document" "s3_access" {
  count = var.enable_s3_access ? 1 : 0

  statement {
    sid    = "CriblS3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = var.s3_allowed_buckets
  }
}

resource "aws_iam_policy" "cribl_s3_access" {
  count       = var.enable_s3_access ? 1 : 0
  name        = "${var.project}-cribl-s3-access"
  description = "Allow Cribl nodes to access specific S3 buckets"
  policy      = data.aws_iam_policy_document.s3_access[0].json
}

resource "aws_iam_role_policy_attachment" "leader_s3_access" {
  count      = var.enable_s3_access ? 1 : 0
  role       = aws_iam_role.leader_role.name
  policy_arn = aws_iam_policy.cribl_s3_access[0].arn
}

resource "aws_iam_role_policy_attachment" "worker_s3_access" {
  count      = var.enable_s3_access ? 1 : 0
  role       = aws_iam_role.worker_role.name
  policy_arn = aws_iam_policy.cribl_s3_access[0].arn
}
