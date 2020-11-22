#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "go" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "terraform-eks-go-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "go" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.go.id

  tags = map(
    "Name", "terraform-eks-worker-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "go" {
  vpc_id = aws_vpc.go.id

  tags = {
    Name = "terraform-eks-worker"
  }
}

resource "aws_route_table" "go" {
  vpc_id = aws_vpc.go.id

//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = aws_internet_gateway.worker.id
//  }
}

resource "aws_route_table_association" "worker" {
  count = 2

  subnet_id      = aws_subnet.go.*.id[count.index]
  route_table_id = aws_route_table.go.id
}
