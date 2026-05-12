variable "project_name" {
  type = string
}

variable "repository_names" {
  description = "Lista de repositorios ECR"
  type        = list(string)
}