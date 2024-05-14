variable vpc_cidr {
  type        = string
  description = "description"
}

variable machine_type {
  type        = string
  description = "description"
}

variable region {
  type        = string
  description = "description"
}


variable machine_details {
  type        = object({
name=string,
type=string,
ami=string,
public_ip=bool
  })
  description = "description"
}


variable subnets_details {
  type        = list(object({
    name=string,
    cidr=string,
    type=string,
    zone=string

  }))

  description = "description"
}


