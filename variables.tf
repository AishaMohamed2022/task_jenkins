variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "pub1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "pub2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private1_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "private2_cidr" {
  type    = string
  default = "10.0.4.0/24"
}

variable "availability_zone1" {
  type    = string
  default = "us-east-1a"
}

variable "availability_zone2" {
  type    = string
  default = "us-east-1b"
}
