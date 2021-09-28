# Creating Public Subnet 
resource "aws_subnet" "demosubnet" {
  vpc_id                  = "${aws_vpc.demovpc.id}"
  cidr_block             = "${var.subnet_cidr}"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet"
  }
}
