#==============================================================================
# IAM ROLE FOR EC2 INSTANCES (SESSION MANAGER)
# 
# Allows EC2 instances to use AWS Systems Manager Session Manager
# for secure shell access without SSH keys
#==============================================================================

#------------------------------------------------------------------------------
# IAM Role for EC2 Instances
# Trust policy allows EC2 service to assume this role
#------------------------------------------------------------------------------

resource "aws_iam_role" "ec2_ssm_role"{
    name = "jonnys-ec2-ssm-role"

    assume_role_policy = jsonencode( {
        Version ="2012-10-17"
        Statement =[
            {
                Action ="sts:AssumeRole"
                Effect ="Allow"
                Principal ={
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })

tags ={
    Name = "Jonnys-EC2-SSM=Role"

  }

}

#------------------------------------------------------------------------------
# Attach AWS Managed Policy for Session Manager
# Grants permissions needed for Session Manager access
#------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ssm_policy" {
    role     = aws_iam_role.ec2_ssm_role.name
    policy_arn ="arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#------------------------------------------------------------------------------
# IAM Instance Profile
# Wrapper that allows EC2 instances to use the IAM role
#------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "ec2_profile" {
    name ="jonnys-ec2-profile"
    role =aws_iam_role.ec2_ssm_role.name

    tags={
        Name ="Jonnys-EC2-Instance-Profile"
    }
}