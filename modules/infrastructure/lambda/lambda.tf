variable "master" {}
variable "infa" {}
resource "aws_lambda_function" "resource_lamnba_slack_update" {
  architectures = ["x86_64"]
  description   = "Better Slack notifications for AWS CloudWatch"

  environment {
    variables = {
      UNENCRYPTED_HOOK_URL = var.infa.slack_update_hook
    }
  }
  
  filename                       = "../../base/software/${var.master.slack_notify_function}"
  function_name                  = "SlackNotify-System-Updates-${var.infa.lane}"
  handler                        = "index.handler"
  memory_size                    = "128"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::${var.master.aws_account_id}:role/${var.master.company}-CloudWatch-Slack"
  runtime                        = "nodejs14.x"
  timeout                        = "60"

  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_sns_topic" "resource_sns_topic_system-update" {
  application_success_feedback_sample_rate = "0"
  content_based_deduplication              = "false"
  fifo_topic                               = "false"
  firehose_success_feedback_sample_rate    = "0"
  http_success_feedback_sample_rate        = "0"
  lambda_success_feedback_sample_rate      = "0"
  name                                     = "SlackNotify-System-Updates-${var.infa.lane}"

  policy = <<POLICY
{
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish"
      ],
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "089613740549"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Resource": "arn:aws:sns:us-west-2:089613740549:SlackNotify-System-Updates-${var.infa.lane}",
      "Sid": "__default_statement_ID"
    }
  ],
  "Version": "2008-10-17"
}
POLICY

  sqs_success_feedback_sample_rate = "0"
}

resource "aws_sns_topic_subscription" "resource_sns_topic_update_sub" {
  endpoint             = "arn:aws:lambda:us-west-2:${var.master.aws_account_id}:function:SlackNotify-System-Updates-${var.infa.lane}"
  protocol             = "lambda"
  raw_message_delivery = "false"
  topic_arn            = aws_sns_topic.resource_sns_topic_system-update.arn
}
resource "aws_lambda_permission" "with_sns_update" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "SlackNotify-System-Updates-${var.infa.lane}"
    principal = "sns.amazonaws.com"
    source_arn = aws_sns_topic.resource_sns_topic_system-update.arn
}

resource "aws_lambda_function" "resource_lamnba_slack_alert" {
  architectures = ["x86_64"]
  description   = "Better Slack notifications for AWS CloudWatch"

  environment {
    variables = {
      UNENCRYPTED_HOOK_URL = var.infa.slack_alert_hook
    }
  }
  
  filename                       = "../../base/software/${var.master.slack_notify_function}"
  function_name                  = "SlackNotify-System-Alerts-${var.infa.lane}"
  handler                        = "index.handler"
  memory_size                    = "128"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::${var.master.aws_account_id}:role/${var.master.company}-CloudWatch-Slack"
  runtime                        = "nodejs14.x"
  timeout                        = "60"

  tracing_config {
    mode = "PassThrough"
  }
}



///////////////////////////////////////
resource "aws_sns_topic" "resource_sns_topic_system-alerts" {
  application_success_feedback_sample_rate = "0"
  content_based_deduplication              = "false"
  fifo_topic                               = "false"
  firehose_success_feedback_sample_rate    = "0"
  http_success_feedback_sample_rate        = "0"
  lambda_success_feedback_sample_rate      = "0"
  name                                     = "SlackNotify-System-Alerts-${var.infa.lane}"

  policy = <<POLICY
{
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish"
      ],
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "089613740549"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Resource": "arn:aws:sns:us-west-2:${var.master.aws_account_id}:SlackNotify-System-Alerts-${var.infa.lane}",
      "Sid": "__default_statement_ID"
    }
  ],
  "Version": "2008-10-17"
}
POLICY

  sqs_success_feedback_sample_rate = "0"
}

resource "aws_sns_topic_subscription" "resource_sns_topic_alerts_sub" {
  endpoint             = "arn:aws:lambda:us-west-2:${var.master.aws_account_id}:function:SlackNotify-System-Alerts-${var.infa.lane}"
  protocol             = "lambda"
  raw_message_delivery = "false"
  topic_arn            = aws_sns_topic.resource_sns_topic_system-alerts.arn
}


resource "aws_lambda_permission" "with_sns_alerts" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "SlackNotify-System-Alerts-${var.infa.lane}"
    principal = "sns.amazonaws.com"
    source_arn = aws_sns_topic.resource_sns_topic_system-alerts.arn
}

resource "aws_lambda_function" "resource_lamnba_slack_logs" {
  architectures = ["x86_64"]
  description   = "Better Slack notifications for AWS CloudWatch"

  environment {
    variables = {
      UNENCRYPTED_HOOK_URL = var.infa.slack_logs_hook
    }
  }
  
  filename                       = "../../base/software/${var.master.slack_notify_function}"
  function_name                  = "SlackNotify-System-Logs-${var.infa.lane}"
  handler                        = "index.handler"
  memory_size                    = "128"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::${var.master.aws_account_id}:role/${var.master.company}-CloudWatch-Slack"
  runtime                        = "nodejs14.x"
  timeout                        = "60"

  tracing_config {
    mode = "PassThrough"
  }
}
