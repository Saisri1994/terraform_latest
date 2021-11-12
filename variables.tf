variable "access"{
}
variable "secret"{
}
variable "subnet_cidr" {
  default = ["10.0.0.0/24", "10.0.8.0/24", "10.0.7.0/24", "10.0.9.0/24"]
}
variable "instances"{
  default = "t2.micro"
}
variable "subnet_azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
