variable "conf" {}
variable "app" {}
variable "app_name" {}
variable "master" {}

resource "aws_cloudwatch_log_group" "cw-loggroup" {

  name              = "${var.conf.lane}-${var.app_name}"
  retention_in_days = "14"
}

resource "aws_cloudwatch_metric_alarm" "alarm_name" {

  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:${var.master.region}:${var.master.aws_account_id}:SlackNotify-System-Alerts-${var.conf.lane}"]
  alarm_name          = "${var.conf.lane}-${var.app_name}-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "2"
  evaluation_periods  = "4"

  metric_query {
    id = "m1"

    metric {
      dimensions = {
        ClusterName          = "${var.conf.lane_full}"
        TaskDefinitionFamily = "${var.conf.lane}-${var.app_name}"
      }

      metric_name = "CpuUtilized"
      namespace   = "ECS/ContainerInsights"
      period      = "60"
      stat        = "Maximum"
    }

    return_data = "false"
  }

  metric_query {
    id = "m2"

    metric {
      dimensions = {
        ClusterName          = "${var.conf.lane_full}"
        TaskDefinitionFamily = "${var.conf.lane}-${var.app_name}"
      }

      metric_name = "CpuReserved"
      namespace   = "ECS/ContainerInsights"
      period      = "60"
      stat        = "Maximum"
    }

    return_data = "false"
  }

  metric_query {
    expression  = "100*(m1/m2)"
    id          = "e1"
    label       = "Percent CPU"
    return_data = "true"
  }


  threshold          = "85"
  treat_missing_data = "missing"
}

resource "aws_cloudwatch_log_metric_filter" "metric_filter" {
  
  name           = "${var.conf.lane}-${var.app_name}-error"
  pattern        = var.app.cw_filter_pattern
  log_group_name = "${aws_cloudwatch_log_group.cw-loggroup.name}"

  metric_transformation {
    name          = "${var.conf.lane}-${var.app_name}-error"
    namespace     = "System-App-Custom"
    default_value = "0"
    value         = "1"
  }
}
resource "aws_lambda_permission" "logging" {
  
  action        = "lambda:InvokeFunction"
  function_name = "SlackNotify-System-Logs-${var.conf.lane}"
  principal     = "logs.${var.master.region}.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.cw-loggroup.arn}:*"
}
resource "aws_cloudwatch_log_subscription_filter" "logging" {
  
  destination_arn = "arn:aws:lambda:${var.master.region}:${var.master.aws_account_id}:function:SlackNotify-System-Logs-${var.conf.lane}"
  filter_pattern  = var.app.cw_filter_pattern
  name            = "${var.conf.lane}-${var.app_name}-ERROR"
  log_group_name  = "${aws_cloudwatch_log_group.cw-loggroup.name}"
}

//set up alarms for metrics in cloud watch for errors
resource "aws_cloudwatch_metric_alarm" "alarm-app-error" {
 
  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:${var.master.region}:${var.master.aws_account_id}:SlackNotify-System-Alerts-${var.conf.lane}"]
  alarm_name          = "${var.conf.lane}-${var.app_name}-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  metric_name         = "${var.conf.lane}-${var.app_name}-error"
  namespace           = "System-App-Custom"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"
}

//set up alarms for metrics in cloud watch for memory
resource "aws_cloudwatch_metric_alarm" "alarm-app-memory" {

  actions_enabled     = "true"
  alarm_actions       = ["arn:aws:sns:${var.master.region}:${var.master.aws_account_id}:SlackNotify-System-Alerts-${var.conf.lane}"]
  alarm_name          = "${var.conf.lane}-${var.app_name}-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "2"
  evaluation_periods  = "4"

  metric_query {
    id = "m1"

    metric {
      dimensions = {
        ClusterName          = "${var.conf.lane_full}"
        TaskDefinitionFamily = "${var.conf.lane}-${var.app_name}"
      }

      metric_name = "MemoryUtilized"
      namespace   = "ECS/ContainerInsights"
      period      = "60"
      stat        = "Maximum"
    }

    return_data = "false"
  }

  metric_query {
    id = "m2"

    metric {
      dimensions = {
        ClusterName          = "${var.conf.lane_full}"
        TaskDefinitionFamily = "${var.conf.lane}-${var.app_name}"
      }

      metric_name = "MemoryReserved"
      namespace   = "ECS/ContainerInsights"
      period      = "60"
      stat        = "Maximum"
    }

    return_data = "false"
  }

  metric_query {
    expression  = "100*(m1/m2)"
    id          = "e1"
    label       = "PercentMem"
    return_data = "true"
  }

  threshold          = "80"
  treat_missing_data = "missing"
}
