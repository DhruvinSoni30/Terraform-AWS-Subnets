# Creating EC2 instance in Public Subnet
resource "aws_instance" "demoinstance" {
  ami           = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
  count = 1
  key_name = "tests"
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.demoinstance.id
  associate_public_ip_address = true

  tags = {
    Name = "My Public Instance"
  }
}

# Creating EC2 instance in Private Subnet
resource "aws_instance" "demoinstance1" {
  ami           = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
  count = 1
  key_name = "tests"
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.demosubnet2.id

  tags = {
    Name = "My Private Instance"
  }
}