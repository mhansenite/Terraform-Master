variable "conf" {}
variable "app" {}
variable "master" {}
variable "app_name" {}

resource "aws_cloudwatch_log_group" "cw-loggroup" {


  name              = "${var.conf.lane}-${var.app_name}"
  retention_in_days = "14"
  tags = {
    env = var.conf.lane
    use = var.app.app_use
  }
}

data "aws_instance" "data_ec2" {
  filter {
    name   = "tag:Name"
    values = ["${var.conf.lane}-${var.app_name}"] 
  }
   filter {
    name   = "instance-state-name"
    values = ["pending", "running" ]
    
  }
}
output "my_ec2_instance1" {
  value = data.aws_instance.data_ec2
  
}
data "aws_lb" "my_lb" {
  name = "${var.conf.lane}-${var.app.lb_connect}-LB"
}

data "aws_lb_target_group" "target_gp" {
  name = "${var.conf.lane}-${var.app_name}-TG"
}

resource "aws_cloudwatch_metric_alarm" "resource_alarm_cpu" {
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:${var.master.region}:${var.master.aws_account_id}:SlackNotify-System-Alerts-${var.conf.lane}"]
  alarm_name          = "${var.conf.lane}-${var.app_name}-cpu"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "8"
  tags = {
    env = var.conf.lane
    use = var.app.app_use
  }

  dimensions = {
    InstanceId = data.aws_instance.data_ec2.id
  }

  evaluation_periods = "8"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Maximum"
  threshold          = "80"
  treat_missing_data = "missing"
}
resource "aws_cloudwatch_metric_alarm" "hostdown" {
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:${var.master.region}:${var.master.aws_account_id}:SlackNotify-System-Alerts-${var.conf.lane}"]
  alarm_name          = "${var.conf.lane}-${var.app_name}-hostDown"
  comparison_operator = "LessThanOrEqualToThreshold"
  datapoints_to_alarm = "1"
  tags = {
    env = var.conf.lane
    use = var.app.app_use
  }

  dimensions = {
    LoadBalancer = substr(data.aws_lb.my_lb.arn,65,-1)
    TargetGroup  = substr(data.aws_lb_target_group.target_gp.arn,52,-1)
  }

  evaluation_periods = "1"
  metric_name        = "HealthyHostCount"
  namespace          = "AWS/ApplicationELB"
  period             = "60"
  statistic          = "Sum"
  threshold          = "0"
  treat_missing_data = "missing"
}

resource "aws_cloudwatch_log_metric_filter" "metric_filter" {
  
  name           = "${var.conf.lane}-${var.app_name}-error"
  pattern        = var.app.cw_filter_pattern
  log_group_name = "${aws_cloudwatch_log_group.cw-loggroup.name}"


  metric_transformation {
    name          = "${var.conf.lane}-${var.app_name}-error"
    namespace     = "${var.app.domain}-App-Custom"
    default_value = "0"
    value         = "1"
  }
}
resource "aws_lambda_permission" "resource_logging_permission" {
  
  action        = "lambda:InvokeFunction"
  function_name = "SlackNotify-System-Logs-${var.conf.lane}"
  principal     = "logs.${var.master.region}.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.cw-loggroup.arn}:*"
}
resource "aws_cloudwatch_log_subscription_filter" "resource_logging_filter" {
  
  destination_arn = "arn:aws:lambda:${var.master.region}:${var.master.aws_account_id}:function:SlackNotify-System-Logs-${var.conf.lane}"
  filter_pattern  = var.app.cw_filter_pattern
  name            = "${var.conf.lane}-${var.app_name}-ERROR"
  log_group_name  = "${aws_cloudwatch_log_group.cw-loggroup.name}"
}

//set up alarms for metrics in cloud watch for errors
resource "aws_cloudwatch_metric_alarm" "resource_app_error" {

  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:${var.master.region}:${var.master.aws_account_id}:SlackNotify-System-Alerts-${var.conf.lane}"]
  alarm_name          = "${var.conf.lane}-${var.app_name}-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  metric_name         = "${var.conf.lane}-${var.app_name}-error"
  namespace           = "${var.app.domain}-App-Custom"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"
  tags = {
    env = var.conf.lane
    use = var.app.app_use
  }
}

//set up alarms for metrics in cloud watch for memory
resource "aws_cloudwatch_metric_alarm" "resource_alarm_mem" {
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:${var.master.region}:${var.master.aws_account_id}:SlackNotify-System-Alerts-${var.conf.lane}"]
  alarm_name          = "${var.conf.lane}-${var.app_name}-memory"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "6"

  dimensions = {
    InstanceId   = data.aws_instance.data_ec2.id
  }

  evaluation_periods = "6"
  metric_name        = "mem_used_percent"
  namespace          = "CWAgent"
  period             = "300"
  statistic          = "Maximum"
  threshold          = "80"
  treat_missing_data = "missing"
  tags = {
    env = var.conf.lane
    use = var.app.app_use
  }
}
