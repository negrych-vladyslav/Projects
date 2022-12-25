variable "region" {
  default = "eu-west-1"
}
variable "ports" {
  default = ["80"]
}
variable "name" {
  default = "wp-docker"
}
variable "cpu" {
  default = "512"
}
variable "memory" {
  default = "3072"
}
locals {
  rds_username = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["username"]
  rds_password = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["password"]
}
