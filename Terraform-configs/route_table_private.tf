resource "aws_route_table" "rt_private" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "Route Table for Isolated Private Subnet"
    }
}

resource "aws_route_table_association" "rt_associate_private_2" {
    subnet_id = aws_subnet.demosubnet2.id
    route_table_id = aws_route_table.rt_private.id
}