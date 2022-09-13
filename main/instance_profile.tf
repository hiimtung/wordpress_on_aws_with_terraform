resource "aws_iam_instance_profile" "this" {
  name = var.asg_iam_instance_profile
  role = aws_iam_role.role.name
}
resource "aws_iam_role" "role" {
  name               = var.asg_iam_instance_profile
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  inline_policy {
    name   = "S3"
    policy = data.aws_iam_policy_document.inline_policy_s3.json
  }
  inline_policy {
    name   = "CloudFront"
    policy = data.aws_iam_policy_document.inline_policy_cloudfront.json
  }
}

# IAM Policies for IAM Instance Profile
data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "inline_policy_s3" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:ListBucket"
    ]
    effect = "Allow"
    resources = [
      module.s3_static.s3_bucket_arn
    ]
  }
  statement {
    sid     = "W3TC"
    actions = local.s3_allow_actions
    effect  = "Allow"
    resources = [
      "${module.s3_static.s3_bucket_arn}/*"
    ]
  }
}
data "aws_iam_policy_document" "inline_policy_cloudfront" {
  statement {
    sid = "W3TC"
    actions = [
      "cloudfront:ListDistributions"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}