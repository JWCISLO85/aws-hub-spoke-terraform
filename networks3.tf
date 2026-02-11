#=======================================================
# Hub VPC-Jonny's Central Management Network
#=======================================================
#Hub Jonnys _Central management network for MSP evirnonment
#Using 10.0.0.0/16 IP range 2^16 = 65,536 IPs
resource "aws_vpc" "jonnys_hub_vpc" {
  cidr_block = "10.0.0.0/16"
  #DNS settings- required for EC2 instances to communicate
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Jonnys-Hub"
  }
}


#Internet Gateway -provides internet access for the hub
resource "aws_internet_gateway" "hub_igw" {
  #This the name of the VPC that the gateway needs to be attached to
  vpc_id = aws_vpc.jonnys_hub_vpc.id
  tags = {
    Name = "Jonnys_Hub_IGW"
  }
}


#Public subnet-for internet-facing resources such as a security scanner
resource "aws_subnet" "hub_public" {
  cidr_block = "10.0.1.0/24"
  #This is the location where this subnet will be inside the 10.0.0.0/16
  vpc_id = aws_vpc.jonnys_hub_vpc.id
  #Data centre location
  availability_zone = "us-east-1a"
  #Gives instances public IPs when launched
  map_public_ip_on_launch = true

  tags = {
    Name = "Jonnys-Hub-Public-Subnet"
  }
}


#Private Subnet-for internal resources (no direct internet access)
resource "aws_subnet" "hub_private" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.jonnys_hub_vpc.id
  #Data centre location
  availability_zone = "us-east-1a"
  #Doesn't give it a public address keeps it private  
  map_public_ip_on_launch = false

  tags = {
    Name = "Jonnys-Hub-Private-Subnet"
  }
}

#===============================================================
# Transit Gateway-The "Main Switch like a core layer 3 switch"
#===============================================================
resource "aws_ec2_transit_gateway" "jonnys_tgw" {
  description = "Jonny's Main Router"

  tags = {
    Name = "Jonnys-Main-TGW"
  }
}

#====================================================================
# Transit Gateway Attachment- The Main Cable connecting Hub to Switch
#====================================================================
resource "aws_ec2_transit_gateway_vpc_attachment" "jonnys_cable" {

  #Plug into Router
  transit_gateway_id = aws_ec2_transit_gateway.jonnys_tgw.id

  #Plug into the Hub VPC (Like a main switch)
  vpc_id = aws_vpc.jonnys_hub_vpc.id

  #The room where the private subnet is
  subnet_ids = [aws_subnet.hub_private.id]

  tags = {
    Name = "Hub-to-TGW-Attachement"
  }
}

#========================================================================
# Client" NovaStream AI Start up
#========================================================================
resource "aws_vpc" "novastream_vpc" {
  cidr_block           = "10.1.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "NovaStream-VPC"
  }
}

#Novastream Subnet
resource "aws_subnet" "novastream_subnet" {
  cidr_block = "10.1.0.0/28"

  vpc_id = aws_vpc.novastream_vpc.id

  availability_zone = "us-east-1a"
  #Keeps it private no public IP
  map_public_ip_on_launch = false

  tags = {
    Name = "NovaStream-Private-Subnet"
  }
}

#========================================================================
# Transit Gateway Attachment Cables to the Hub
#========================================================================
resource "aws_ec2_transit_gateway_vpc_attachment" "novastream_cable" {

  #Plug into Router
  transit_gateway_id = aws_ec2_transit_gateway.jonnys_tgw.id

  #Plug into the NovaStream VPC
  vpc_id = aws_vpc.novastream_vpc.id

  #The room where the private subnet is
  subnet_ids = [aws_subnet.novastream_subnet.id]

  tags = {
    Name = "Novastream-To_TGW"
  }
}

#======================================================================
# Client Healthcare Startup
#=======================================================================
resource "aws_vpc" "healthcare_vpc" {
  cidr_block           = "10.2.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Healthcare-VPC"
  }
}

#Healthcare subnet
resource "aws_subnet" "healthcare_subnet" {
  cidr_block              = "10.2.0.0/28"
  map_public_ip_on_launch = false

  vpc_id = aws_vpc.healthcare_vpc.id

  availability_zone = "us-east-1a"

  tags = {
    Name = "Healthcare-Private-Subnet"
  }
}

#========================================================================
# Transit Gateway Attachement Cables to the Hub
#========================================================================
resource "aws_ec2_transit_gateway_vpc_attachment" "healthcare_cable" {

  # Plug into Router
  transit_gateway_id = aws_ec2_transit_gateway.jonnys_tgw.id

  #Plug into the Healthcare VPC
  vpc_id = aws_vpc.healthcare_vpc.id

  # The room where the private subnet is
  subnet_ids = [aws_subnet.healthcare_subnet.id]

  tags = {
    Name = "Healthcare-To_TGW"
  }
}

#===============================================================
#Route table Jonnys Hub
#=================================================================
#Takes control of VPCs default route table
resource "aws_default_route_table" "hub_route" {
  
  #Points to the default route table that AWS created when VPC was made
  default_route_table_id = aws_vpc.jonnys_hub_vpc.default_route_table_id

#All internet bound traffic
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hub_igw.id
  }


route { 
cidr_block = "10.2.0.0/24"
transit_gateway_id = aws_ec2_transit_gateway.jonnys_tgw.id
}


route { 
cidr_block = "10.1.0.0/24"
transit_gateway_id = aws_ec2_transit_gateway.jonnys_tgw.id
}

tags = {Name = "jonnys-hub-route-table"
}
} 


#====================================================================================
# Route table Novastream
#=====================================================================================

#Takes control of VPCs default route table
resource "aws_default_route_table" "novastream_route" {
  
  #Points to the default route table that AWS created when VPC was made
  default_route_table_id = aws_vpc.novastream_vpc.default_route_table_id

#All internet bound traffic to transit gateway which takes it to the hub
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.jonnys_tgw.id
  }

tags = {Name = "novastream-route-table"
}
} 
#==========================================================================
# Route Table  Healthcare
#==========================================================================

#Takes control of VPCs default route table
resource "aws_default_route_table" "healthcare_route" {
  
  #Points to the default route table that AWS created when VPC was made
  default_route_table_id = aws_vpc.healthcare_vpc.default_route_table_id

#All internet bound traffic transit gateway which takes it to the hub
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.jonnys_tgw.id
  }


tags = {Name = "healthcare-route-table"
}
} 