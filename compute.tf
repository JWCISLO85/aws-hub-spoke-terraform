#======================================
# Novastream EC2 instances
#======================================

resource "aws_instance" "novastream_server"{
    ami  ="ami-02dfbd4ff395f2a1b"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.novastream_subnet.id


vpc_security_group_ids = [aws_security_group.novastream_sg.id]

key_name               = aws_key_pair.hub_key.key_name
iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
tags ={
    Name = "novastream-static-webpage-server"
}
}

#===============================================
# Healthcare EC2 instances
#===============================================

resource "aws_instance" "healthcare_server" {
    ami = "ami-02dfbd4ff395f2a1b"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.healthcare_subnet.id

    vpc_security_group_ids = [aws_security_group.healthcare_sg.id]

    key_name = aws_key_pair.hub_key.key_name
    iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
    tags = {
        Name ="healthcare-server"
    }
}
#-------------------------------------------------
# Bastion Host - EC2 Instance in public subnet
#--------------------------------------------------
resource "aws_instance" "bastion" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t2.micro"
  
  subnet_id     = aws_subnet.hub_public.id

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  key_name = aws_key_pair.hub_key.key_name

  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "Jonnys-Bastion-Host"
    Role = "Bastion"
  }
}