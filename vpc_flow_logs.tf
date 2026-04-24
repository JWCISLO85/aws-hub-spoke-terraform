#Creates a container in CloudWatch Logs where VPC flow log data will be stored

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
    name                       ="/vpc/flowlogs"
    retention_in_days          = 7




tags ={
    Name ="Jonnys-VPC-Flow-Logs"
}

}



#------------------------------------------------------------------------------
# VPC Flow Logs IAM Role
# 
# Grants VPC Flow Logs service permission to write network traffic logs
# to CloudWatch. This role is assumed by vpc-flow-logs.amazonaws.com service.
#------------------------------------------------------------------------------

resource "aws_iam_role" "vpc_flow_logs_role"{
    name = "jonnys-vpc-flow-logs-role"

    assume_role_policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect ="Allow"
                Principal = {
                    Service = "vpc-flow-logs.amazonaws.com"
                }
            }
        ]
    })
    tags = {

  Name   =  "Jonnys-VPC-Flow-Logs-Role"
    }
}

#------------------------------------------------------------------------------
# IAM Policy for VPC Flow Logs
# Defines permissions for creating log groups, streams, and writing events
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "vpc_flow_logs_policy"{
    name = "jonnys-vpc-flow-logs-policy"
    role = aws_iam_role.vpc_flow_logs_role.id


    policy =jsonencode ({

    Version = "2012-10-17"
    Statement =[
        {
            Action = [
                "logs:CreateLogGroup" ,
                "logs:CreateLogStream" ,
                "logs:PutLogEvents",
                "logs:DescribeLogGroups" ,
                "logs:DescribeLogStreams"
            ]
        Effect  = "Allow"
        Resource ="*"
        }
        
    ]
})
}

#------------------------------------------------------------------------------
# VPC Flow Log - Hub VPC
# Monitors all network traffic (accepted and rejected) in Hub VPC
#------------------------------------------------------------------------------

resource "aws_flow_log" "vpc_flow_logs_policy"{
vpc_id                 = aws_vpc.jonnys_hub_vpc.id
log_destination        = aws_cloudwatch_log_group.vpc_flow_logs.arn
iam_role_arn           = aws_iam_role.vpc_flow_logs_role.arn
traffic_type           = "ALL"


tags = {
    Name ="Jonnys-Hub-VPC-Flow-Logs"
}
}

#------------------------------------------------------------------------------
# VPC Flow Log - NovaStream VPC
# Monitors all network traffic (accepted and rejected) in NovaStream VPC
#------------------------------------------------------------------------------

resource "aws_flow_log" "novastream_flow_log" {
vpc_id           = aws_vpc.novastream_vpc.id 
traffic_type     = "ALL"
iam_role_arn     = aws_iam_role.vpc_flow_logs_role.arn
log_destination  = aws_cloudwatch_log_group.vpc_flow_logs.arn

tags = {
    Name ="Novastream-Flow-Logs"
}

}

#------------------------------------------------------------------------------
# VPC Flow Log - Healthcare VPC
# Monitors all network traffic (accepted and rejected) in Healthcare VPC
#------------------------------------------------------------------------------

resource "aws_flow_log" "healthcare_flow_log"{
vpc_id         = aws_vpc.healthcare_vpc.id
traffic_type   = "ALL"
iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn

tags = {
    Name = "Healthcare-Flow-Logs"
}

}


     
