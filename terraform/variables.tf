variable "region" {
  description = "Region AWS"
  type = string
  default = "us-east-1"
}

variable "cluster_name" {
  description = "Nome cluster EKS"
  type = string
  default = "cluster-simone"
}
