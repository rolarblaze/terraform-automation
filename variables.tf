variable "vpc_name" {
  type        = string
  description = "The name of our vpc "
  default     = "test"
}

variable "pub_subnet" {
  type        = string
  description = "Creating a public subnet"
  default     = "public subnet"
}

variable "instance_name" {
  type        = string
  description = "Creating a public subnet"
  default     = "Dev Server"
}