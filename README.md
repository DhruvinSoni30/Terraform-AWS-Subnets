# How to manage Public and Private subnets in AWS with Terraform?

### What is Terraform? 

Terraform is an open-source infrastructure as a code (IAC) tool that allows to create, manage & deploy the production-ready environment. Terraform codifies cloud APIs into declarative configuration files. Terraform can manage both existing service providers and custom in-house solutions.

![1](https://github.com/DhruvinSoni30/Terraform-AWS-Subnets/blob/main/1.png)

### What is Subnet?

A subnet is a logical subdivision of an IP network. By dividing a network into two or more networks is called subnetting. One part identifies the host part, the other part identifies the network part.

![2](https://github.com/DhruvinSoni30/Terraform-AWS-Subnets/blob/main/2.png)

### Types of subnet:
* **Public Subnet:**
  A public subnet is a subnet that's associated with the Route table that has a route to an internet gateway. This connects the VPC to the internet and to other AWS services. Instance launched in the public subnet will assign IP address by default.
  
* **Private Subnet:**
  Instances in the private subnet are generally back-end servers that don't need to accept incoming traffic from the internet and therefore do not have public IP addresses. However, they can send requests to the internet using the NAT gateway or NAT instance.
  
![3](https://github.com/DhruvinSoni30/Terraform-AWS-Subnets/blob/main/3.png)

In this article, I will explain how to create and manage the public and private subnets using terraform.

### Prerequisites:
* Basic knowledge of AWS & Terraform
* AWS account
* AWS Access & Secret Key

> In this project I have used some variables also that I will discuss later in this article.

**Step 1:- Create a file for the VPC**
  
* Create vpc.tf file and add the below code to it
  
  ```
  # Creating VPC
  resource "aws_vpc" "demovpc" {
    cidr_block       = "${var.vpc_cidr}"
    instance_tenancy = "default"
  tags = {
    Name = "Demo VPC"
  }
  }
  ```

**Step 2:- Create a file for the Public Subnet**

* Create public_subnet.tf file and add the below code to it

  ```
  # Creating Public Subnet for EC2 instance
  resource "aws_subnet" "demosubnet" {
    vpc_id                  = "${aws_vpc.demovpc.id}"
    cidr_block             = "${var.subnet_cidr}"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet"
  }
  }
  ```

* As of now, this subnet will not act as the public subnet, we need to create the internet gateway and also need to update the route table so, let's do that.

**Step 3:- Create a file for the Internet Gateway**

* Create igw.tf file and add the below code to it

  ```
  # Creating Internet Gateway 
  resource "aws_internet_gateway" "demogateway" {
    vpc_id = "${aws_vpc.demovpc.id}"
  }
  ```

**Step 4:- Create a file for the Route table for the Public Subnet**

* Create route_table_public.tf file and add the below code to it

  ```
  # Creating Route Table for Public Subnet
  resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.demovpc.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demogateway.id
    }
  tags = {
        Name = "Public Subnet Route Table"
    }
  }
  resource "aws_route_table_association" "rt_associate_public" {
    subnet_id = aws_subnet.demosubnet.id
    route_table_id = aws_route_table.rt.id
  }
  ```

* In the above code, I am creating a new route table and forwarding all the requests to the 0.0.0.0/0 CIDR block.
* I am also attaching this route table to the subnet created earlier. So, it will work as the Public Subnet

**Step 5:- Create a file for the Security Group**

* Create sg.tf file and add the below code to it

  ```
  # Creating Security Group 
  resource "aws_security_group" "demosg" {
    vpc_id      = "${aws_vpc.demovpc.id}"
    # Inbound Rules
    # HTTP access from anywhere
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    # HTTPS access from anywhere
    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    # SSH access from anywhere
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    # Outbound Rules
    # Internet access to anywhere
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ```
* I have opened 80,443 & 22 ports for the inbound connection and I have opened all the ports for the outbound connection

**Step 6:- Create a file for the Public EC2 instance**

* Create ec2_public.tf file and add the below code to it
  
  ```
  # Creating EC2 instance in Public Subnet
  resource "aws_instance" "demoinstance" {
    ami           = "ami-087c17d1fe0178315"
    instance_type = "t2.micro"
    key_name = "tests"
    vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
    subnet_id = aws_subnet.demoinstance.id
    associate_public_ip_address = true
  tags = {
    Name = "My Public Instance"
  }
  }
  ```

**Step 7:- Create a file for the Public Subnet for NAT Gateway**

* Create public_subnet_NAT.tf file and add the below code to it

  ```
  # Creating Public subnet for NAT Gateway 
  resource "aws_subnet" "demosubnet1" {
    vpc_id                  = "${aws_vpc.demovpc.id}"
    cidr_block             = "${var.subnet1_cidr}"
    availability_zone = "us-east-1b"
  tags = {
    Name = "Public Subnet for NAT Gateway"
  }
  }
  ```

**Step 8:- Create a file for the EIP**

* You can not launch NAT Gateway without an Elastic IP address so, let's create it first
* Create eip.tf file and add the below code to it

  ```
  # Creating EIP
  resource "aws_eip" "eip" {
    vpc = true
  }
  ```

**Step 9:- Create a file for the NAT Gateway**
  
* Create nat.tf file and add the below code to it

  ```
  # Creating NAT Gateway
  resource "aws_nat_gateway" "gw" {
    allocation_id = aws_eip.eip.id
    subnet_id     = aws_subnet.demosubnet.id
  }
  ```

**Step 10:- Create a file for the Route table for the NAT Gateway**
  
* Create route_table_private.tf file and add the below code to it

  ```
  # Creating Route Table for NAT Gateway
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
    route_table_id = aws_route_table.rt_private.id
  }
  ```

**Step 11:- Create a file for the Private Subnet**

* Create private_subnet.tf file and add the below code to it

  ```
  # Creating Private subnet 
  resource "aws_subnet" "demosubnet2" {
    vpc_id                  = "${aws_vpc.demovpc.id}"
    cidr_block             = "${var.subnet1_cidr}"
    availability_zone = "us-east-1b"
  tags = {
    Name = "Private Subnet"
  }
  }
  ```

* As of now, this subnet will not act as the private subnet, we need to do some modifications.

**Step 12:- Create a file for the Route table for the Private Subnet**

* Create a route_table_private.tf file and add the below code to it.
  
  ```
  # Creating Route table for Private Subnet
  resource "aws_route_table" "rt_private" {
    vpc_id = aws_vpc.my_vpc.id
  tags = {
        Name = "Route Table for the Private Subnet"
    }
  }
  resource "aws_route_table_association" "rt_associate_private_2" {
    subnet_id = aws_subnet.demosubnet2.id
    route_table_id = aws_route_table.rt_private.id
  }
  ```
  
* In the above code, I have created the Route Table with no routes declaration and associate it with our private Subnet

**Step 13:- Create a file for an EC2 instance in the Private subnet**

* Create a ec2_private.tf file and add the below code to it
  
  ```
  # Creating EC2 instance in Private Subnet
  resource "aws_instance" "demoinstance1" {
    ami           = "ami-087c17d1fe0178315"
    instance_type = "t2.micro"
    key_name = "tests"
    vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
    subnet_id = aws_subnet.demosubnet2.id
  tags = {
    Name = "My Private Instance"
  }
  }
  ```

**Step 14:- Create a variable file**

* Create vars.tf file and add the below code to it

  ```
  # Defining CIDR Block for VPC
  variable "vpc_cidr" {
    default = "10.0.0.0/16"
  } 
  # Defining CIDR Block for 1st Subnet
  variable "subnet_cidr" {
    default = "10.0.1.0/24"
  }
  # Defining CIDR Block for 2nd Subnet
  variable "subnet1_cidr" {
    default = "10.0.2.0/24"
  }
  # Defining CIDR Block for 3rd Subnet
  variable "subnet2_cidr" {
    default = "10.0.3.0/24"
  }
  ```

So, now our entire code is ready. We need to run the below steps to create infrastructure.

* terraform init is to initialize the working directory and downloading plugins of the provider
* terraform plan is to create the execution plan for our code
* terraform apply is to create the actual infrastructure. It will ask you to provide the Access Key and Secret Key in order to create the infrastructure. So, instead of hardcoding the Access Key and Secret Key, it is better to apply at the run time.

**Step 15:- Verify the resources**

* Terraform will create below resources

  * **VPC**
  * **Public Subnet for EC2 instance & NAT Gateway**
  * **Private Subnet for EC2 Instance**
  * **Route table for Public & Private Subnets and NAT Gateway**
  * **Internet Gateway**
  * **EIP**
  * **NAT Gateway**
  * **Security Group**
  * **EC2 instances**

That's it now, you have learned how to create various resources in AWS using Terraform.
