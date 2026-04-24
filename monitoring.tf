
#===========================================
# SNS Topic -CloudWatch Alert Notifications
#===========================================
resource "aws_sns_topic" "alerts" {
  name = "cloudwatch-alerts" 
  

tags = {
    Name = "CloudWatch-Alerts"
}
}

#============================================
# Email Subscription
#============================================

resource "aws_sns_topic_subscription" "email_alerts" {
    endpoint = var.email
    protocol = "email"
    topic_arn = aws_sns_topic.alerts.arn
}

#=======================================
# Alarm for CPU Utilization Novastream
#=======================================

resource "aws_cloudwatch_metric_alarm" "novastream_high_cpu" {
 alarm_name = "HighCPU-Novastream"
 metric_name ="CPUUtilization"
 namespace   = "AWS/EC2"
 comparison_operator = "GreaterThanThreshold"
 evaluation_periods  = 2
 threshold           = 80
 statistic           = "Average"
 period              = 300
 alarm_description   = "Triggers when NovaStream instance CPU exceeds 80% for 10 minutes" 
 
 dimensions = {
    InstanceId= aws_instance.novastream_server.id
  }

    alarm_actions =[aws_sns_topic.alerts.arn]

}

#================================
# Alarm For Instance Check Failed
#=================================

resource "aws_cloudwatch_metric_alarm" "novastream_status_check" {
alarm_name          = "Novastream-StatusCheck"
metric_name         = "StatusCheckFailed"
comparison_operator = "GreaterThanOrEqualToThreshold"
threshold           = 1  # 1 means fail  
evaluation_periods  = 2
namespace           = "AWS/EC2" 
period              = 300
statistic           = "Maximum"
alarm_description   = "Triggers when NovaStream instance fails status checks"
dimensions = {
   InstanceId= aws_instance.novastream_server.id

}

   alarm_actions = [aws_sns_topic.alerts.arn]


}


#=======================================
# Alarm for CPU Utilization Healthcare
#=======================================

resource "aws_cloudwatch_metric_alarm" "healthcare_high_cpu" {
 alarm_name = "HighCPU-Healthcare"
 metric_name ="CPUUtilization"
 namespace   = "AWS/EC2"
 comparison_operator = "GreaterThanThreshold"
 evaluation_periods  = 2
 threshold           = 80
 statistic           = "Average"
 period              = 300
 alarm_description   = "Triggers when NovaStream instance CPU exceeds 80% for 10 minutes" 
 
 dimensions = {
    InstanceId= aws_instance.healthcare_server.id
  }

    alarm_actions =[aws_sns_topic.alerts.arn]

}

#===========================================
# Alarm For Instance Check Failed Healthcare
#===========================================

resource "aws_cloudwatch_metric_alarm" "healthcare_status_check"{
alarm_name          = "Healthcare-StatusCheck"
metric_name         = "StatusCheckFailed"
comparison_operator = "GreaterThanOrEqualToThreshold"
threshold           = 1  # 1 means fail  
evaluation_periods  = 2
namespace           = "AWS/EC2" 
period              = 300
statistic           = "Maximum"
alarm_description   = "Triggers when HealthCare fails stauts check"


dimensions = {
    InstanceId = aws_instance.healthcare_server.id
}

alarm_actions  = [aws_sns_topic.alerts.arn]
}

