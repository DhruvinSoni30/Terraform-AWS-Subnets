# Creating Public subnet for NAT Gateway
resource "aws_subnet" "demosubnet1" {
  vpc_id                  = "${aws_vpc.demovpc.id}"
  cidr_block             = "${var.subnet1_cidr}"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public Subnet for NAT Gateway"
  }
}