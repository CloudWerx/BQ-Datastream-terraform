variable "gcp_project" {
  description = "The ID of the GCP project"
  type        = string
}

variable "gcp_credentials_file" {
  type = string
}

variable "gcp_region" {
  description = "The GCP region"
  default     = "us-central1"
}

variable "aws_region" {
  description = "The AWS region"
  default     = "us-east-1"
}

variable "aurora_connection_info" {
  description = "AWS Aurora PostgreSQL connection details"
  type = object({
    host     = string
    port     = number
    username = string
    password = string
    database = string
  })
}

variable "SSH_Hostname" {
  description = "SSH Tunnel Host"
  type = string
}

variable "SSH_User" {
  type = string
}

variable "SSH_Port" {
  type = number
}

variable "SSH_private_key" {
  type = string
}

variable "datafreshness" {
  description = "Increment of data freshness in seconds, i.e. 90s"
  type = string
}
