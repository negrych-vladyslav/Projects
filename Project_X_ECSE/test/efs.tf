#EFS File System================================================================
resource "aws_efs_file_system" "efs" {
  creation_token = "wordpress-assets"
}
#EFS Mount Targets==============================================================
resource "aws_efs_mount_target" "efs_private_zoneA" {
  file_system_id  = aws_efs_file_system.efs.id
  security_groups = [module.ecs-sg.sg_id]
  subnet_id       = module.ecs-vpc.public_subnets[0]
}

resource "aws_efs_mount_target" "efs_private_zoneB" {
  file_system_id  = aws_efs_file_system.efs.id
  security_groups = [module.ecs-sg.sg_id]
  subnet_id       = module.ecs-vpc.public_subnets[1]
}
