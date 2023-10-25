//variable "aws_secret_key" {}
//variable "aws_access_key" {}
variable "region" {
  default = "us-east-1"
}
variable "mykey" {
  default = "us-east-1-adartis-bahattin"
}
variable "tags" {
  default = "jenkins-server"
}
variable "myami" {
  description = "amazon linux 2 ami"
  default     = "ami-01eccbf80522b562b"
}
variable "instancetype" {
  default = "t2.micro"
}

variable "secgrname" {
  default = "jenkins-server-sec-gr"
}

variable "secgr-dynamic-ports" {
  default = [22, 80, 443, 8080-9000]
}
