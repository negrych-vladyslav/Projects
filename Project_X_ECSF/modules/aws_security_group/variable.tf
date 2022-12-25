variable "ports" {
  default = ["80", "443", "22", "3306"]
}

variable "name" {
  default = "project"
}

variable "vpc_id" {
  default = "vpc-0a6396929e5139e2c"
}
