variable "project_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "sg_ec2_id" {
  type = string
}

variable "target_group_arns" {
  type = list(string)
}

# DB
variable "db_host" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type = string
}