variable "public_subnets" {
    type = list(object({
        cidr_block = string,
        availability_zone = string,
        tags = map(string)
    })) 
}
variable "private_subnets" {
    type = list(object({
        cidr_block = string,
        availability_zone = string,
        tags = map(string)
    })) 
}