variable "master" {}



resource "aws_lambda_function" "resource_lamnba_slack_ops" {

  architectures = ["x86_64"]
  description   = "Better Slack notifications for AWS CloudWatch"

  environment {
    variables = {
      UNENCRYPTED_HOOK_URL = var.master.slack_ops_hook
    }
  }
  
  filename                       = "../base/software/${var.master.slack_notify_function}"
  function_name                  = "SlackNotify-General-Ops-Notifications"
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


resource "aws_lambda_function" "resource_lamnba_slack_ci_fe" {

  architectures = ["x86_64"]
  description   = "Better Slack notifications for AWS CloudWatch"

  environment {
    variables = {
      UNENCRYPTED_HOOK_URL = var.master.slack_ci_fe_hook
    }
  }
  
  filename                       = "../base/software/${var.master.slack_notify_function}"
  function_name                  = "SlackNotify-CI-Frontend-Notifications"
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


resource "aws_lambda_function" "resource_lamnba_slack_ci_be" {

  architectures = ["x86_64"]
  description   = "Better Slack notifications for AWS CloudWatch"

  environment {
    variables = {
      UNENCRYPTED_HOOK_URL = var.master.slack_ci_be_hook
    }
  }
  
  filename                       = "../base/software/${var.master.slack_notify_function}"
  function_name                  = "SlackNotify-CI-Backend-Notifications"
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