#===============================================================================
provider "aws" {}
#===============================================================================
terraform {
  backend "s3" {
    bucket = "vladyslav-negrych-efs"
    key    = "dev/efs/terraform.tfstate"
    region = "eu-west-1"
  }
}
data "terraform_remote_state" "ecs" {
  backend = "s3"
  config = {
    bucket = "vladyslav-negrych-ecs-fargate"
    key    = "dev/ecs/terraform.tfstate"
    region = "eu-west-1"
  }
}
#===============================================================================
resource "aws_efs_file_system" "efs_volume" {
  tags = {
    Name = "efs_volume"
  }
}

resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.efs_volume.id
}
resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.efs_volume.id
  policy         = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Policy01",
    "Statement": [
        {
            "Sid": "Statement",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.efs_volume.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_efs_mount_target" "efs_mt_1" {
  file_system_id  = aws_efs_file_system.efs_volume.id
  subnet_id       = data.terraform_remote_state.ecs.outputs.private_subnet_1
  security_groups = [data.terraform_remote_state.ecs.outputs.sg_id]
}
resource "aws_efs_mount_target" "efs_mt_2" {
  file_system_id  = aws_efs_file_system.efs_volume.id
  subnet_id       = data.terraform_remote_state.ecs.outputs.private_subnet_2
  security_groups = [data.terraform_remote_state.ecs.outputs.sg_id]
}
#===============================================================================
output "efs_id" {
  value = aws_efs_file_system.efs_volume.id
}
