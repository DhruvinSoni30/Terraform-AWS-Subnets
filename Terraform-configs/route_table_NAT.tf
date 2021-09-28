# Creating Route Table for Private Subnet
resource "aws_route_table" "rt_NAT" {
    vpc_id = aws_vpc.demovpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.gw.id
    }

    tags = {
        Name = "Main Route Table for Private subnet"
    }
}

resource "aws_route_table_association" "rt_associate_private" {
    subnet_id = aws_subnet.demosubnet1.id
    route_table_id = aws_route_table.rt_NAT.id
}