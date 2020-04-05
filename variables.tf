variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

variable "key_name" {
  description = "key name"
}

variable "pem_path" {
  description = "pem path"
}

variable "aws_amis" {
  default = "ami-04d5cc9b88f9d1d39"
}

variable "db_identifier" {
    default = "dbrds"
    description = ""
}

variable "engine" {
  default = "mysql"
}

variable "engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.7.28"
    postgres = "9.6.8"
  }
}

variable "instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "storage" {
    default = "10"
    description = "db storage size default 10G"
}

variable "db_name" {
  default     = "mydb"
  description = "db name"
}

variable "db_username" {
  default     = "myuser"
  description = "db username"
}

variable "db_password" {
  description = "db password"
}

variable "web_service" {
  default = "apache"
  description = "choose web service nginx, apache"
}

