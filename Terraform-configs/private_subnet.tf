# Creating Private subnet 
resource "aws_subnet" "demosubnet2" {
  vpc_id                  = "${aws_vpc.demovpc.id}"
  cidr_block             = "${var.subnet2_cidr}"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet"
  }
}