public_subnets = [{
    cidr_block = "10.0.0.0/20",
    availability_zone = "us-east-1a",
    tags = {
        "Name" = "public_subnet_01"
    }
},
{
    cidr_block = "10.0.16.0/20",
    availability_zone = "us-east-1b",
    tags = {
        "Name" = "public_subnet_02"
    }
}]
private_subnets=[{
    cidr_block = "10.0.128.0/20",
    availability_zone = "us-east-1a",
    tags = {
        "Name" = "private_subnet_01"
    }
},
{
    cidr_block = "10.0.144.0/20",
    availability_zone = "us-east-1b",
    tags = {
        "Name" = "private_subnet_02"
    }
}
]