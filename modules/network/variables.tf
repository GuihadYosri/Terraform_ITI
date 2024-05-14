variable "vpc_cidr" {
  type = string
}

variable "subnets_details" {
  type = list(object({
    name = string,
    cidr = string,
    zone=string
  }))
}

variable "region" {
  type = string
}
