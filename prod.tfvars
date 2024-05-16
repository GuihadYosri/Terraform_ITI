vpc_cidr="10.0.0.0/16"
machine_type="t2.micro"
region="eu-central-1"
machine_details={
    name="bastion",
    type="t2.large",
    ami="ami-04b70fa74e45c3917",
    public_ip=true
}

subnets_details=[

{
    name="public1",
    cidr="10.0.1.0/24",
    type="public",
    zone = "us-east-1a",
},

{
    name="public2",
    cidr="10.0.2.0/24",
    type="public",
    zone = "us-east-1b",
},

{
    name="private1",
    cidr="10.0.3.0/24",
    type="private",
    zone = "us-east-1a",
},

{
    name="private2",
    cidr="10.0.4.0/24",
    type="private",
    zone = "us-east-1b",
}


]

