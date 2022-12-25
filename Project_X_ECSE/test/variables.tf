variable "region" {
  default = "eu_west_1"
}
variable "ports" {
  default = ["80", "9000", "2049", "3306", "22"]
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
