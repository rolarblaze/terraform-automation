variable "web_port" {
  description = "opening  port 80 to our public the subnet group"
  type        = number
  default     = 80
}

variable "aws_region" {
  description = "our data centre region"
  type        = string
  default     = "us-east-1"
}
variable "pub_subnet" {
  type        = string
  description = "Creating a public subnet"
  default     = "public subnet"
}

variable "vpc_name" {
  type        = string
  description = "The name of our vpc "
  default     = "test"
}

# this create a variable and list all availability zones within our aws region which we will reference in our main.tf file
variable "a_zs" {
  description = "list all the availability zones within our region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
}

# type map, map more AMIs into a variable 
variable "amis" {
  description = "Map ami from us-west-2 and "
  type        = map(string)
  default = {
    "us-west-2" = "ami-024e6efaf93d85776",
    "us-east-1" = "ami-022e1a32d3f742bd8"
  }
}

# working tuples, tuples accept 3 parameters, a string, an integer, and a boolean value; true or false 
variable "my_instance" {
  type    = tuple([string, number, bool])
  default = ["t3.micro", 1, true]
}

variable "instance_name" {
  description = "Name of my instance"
  type        = string
  default     = "Test Server"
}

# creating a variable with object, object accepts multi argument and statement 
variable "egress_sg" {
  type = object({
    from_port  = number
    to_port    = number
    protocol   = string
    cidr_block = list(string)
  })
  default = {
    cidr_block = ["0.0.0.0/0"]
    from_port  = 0
    protocol   = "-1"
    to_port    = 0
  }
}