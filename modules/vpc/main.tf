provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc-cidr
  instance_tenancy = var.instance-tenancy
  enable_dns_support = "var.enable-dns-support
  enable_dns_hostnames = var.enable-dns-hostnames

  tags {
    Name= var.vpc-name
    Location= var.vpc-location
  }
}

#Creating IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags {
    Name= var.internet-gateway-name

  }
}

#Public subnet 
resource "aws_subnet" "public-subnets" {
  availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
  count = "${length(var.vpc-public-subnet-cidr)}"
  cidr_block = "${element(var.vpc-public-subnet-cidr,count.index)}"
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags {
    Name = ${var.public-subnets-name}-${count.index+1}"
    Location = "${var.public-subnets-location}"
  }
}

#Creating a public RT
resource "aws_route_table" "public-routes" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags {
    Name = var.public-subnet-routes-name
  }
}

#Linking public RT with public subnets
resource "aws_route_table_association" "public-association" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  route_table_id = "${aws_route_table.public-routes.id}"
  subnet_id = "${element(aws_subnet.public-subnets.*.id, count.index)}"
}

#Creating private subnets from the list
resource "aws_subnet" "private-subnets" {
  availability_zone = "${element(data.aws_availability_zones.azs.names,count.index)}"
  count = "${length(var.vpc-private-subnet-cidr)}"
  cidr_block = "${element(var.vpc-private-subnet-cidr,count.index)}"
  vpc_id = "${aws_vpc.vpc.id}"


  tags {
    Name = "${var.private-subnet-name}-${count.index+1}"
    Location = "${var.private-subnets-location-name}"
  }
}

#creating eip for natgateway
resource "aws_eip" "eip-ngw" {
  count = "${var.total-nat-gateway-required}"
  tags {
    Name = "${var.eip-for-nat-gateway-name}-${count.index+1}"
  }
}
#creating NAT gateway
resource "aws_nat_gateway" "ngw" {
  count = "${var.total-nat-gateway-required}"
  allocation_id = "${element(aws_eip.eip-ngw.*.id,count.index)}"
  subnet_id = "${element(aws_subnet.public-subnets.*.id, count.index)}"
  tags {
    Name = "${var.nat-gateway-name}-${count.index+1}"
  }
}

#Creating a private RT for private subnet
resource "aws_route_table" "private-routes" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "${var.private-route-cidr}"
    nat_gateway_id = "${element(aws_nat_gateway.ngw.*.id,count.index)}"
  }
  tags {
    Name = "${var.private-route-name}-${count.index+1}"
  }

}

#Linking Private Route tables to private subnet
resource "aws_route_table_association" "private-routes-linking" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  route_table_id = "${element(aws_route_table.private-routes.*.id,count.index)}"
  subnet_id = "${element(aws_subnet.private-subnets.*.id,count.index)}"
}

