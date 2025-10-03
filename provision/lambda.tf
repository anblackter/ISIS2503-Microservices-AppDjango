# Lambda CloudWatcg log group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 30
}

resource "aws_lambda_function" "api_consumption" {
  # disabled for academical reasons
  function_name = var.lambda_name
  role          = data.aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.api-consumption.repository_url}:latest"
  architectures = ["x86_64"]
  timeout       = 10

  environment {
    variables = {
      "API_PATH" = "https://raw.githubusercontent.com/ISIS2503/ISIS2503-Microservices-AppDjango/master/data/temperatura.json"
      "MS_PATH"  = "http://${aws_instance.measurements_ms.public_ip}:8080/createmeasurements/"
    }
  }

  depends_on = [aws_ecr_repository.api-consumption]
}

# EventBridge Rule for scheduling
resource "aws_cloudwatch_event_rule" "api_consumption_scheduler" {
  name                = "api-consumption-scheduler"
  description         = "Trigger API consumption Lambda every 5 minutes"
  schedule_expression = "rate(5 minutes)"

  tags = {
    Name = "api-consumption-scheduler"
  }
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.api_consumption_scheduler.name
  target_id = "ApiConsumptionLambdaTarget"
  arn       = aws_lambda_function.api_consumption.arn
}

# Lambda Permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_consumption.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.api_consumption_scheduler.arn
}

# Places Lambda
resource "aws_cloudwatch_log_group" "places" {
  name              = "/aws/lambda/places_api_consumption"
  retention_in_days = 30
}


resource "aws_lambda_function" "places_api_consumption" {
  # disabled for academical reasons
  function_name = "places_api_consumption"
  role          = data.aws_iam_role.lambda_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.api-consumption.repository_url}:latest"
  architectures = ["x86_64"]
  timeout       = 10

  environment {
    variables = {
      "API_PATH" = "https://raw.githubusercontent.com/ISIS2503/ISIS2503-Microservices-AppDjango/master/data/oxigeno.json"
      "MS_PATH"  = "http://${aws_instance.measurements_ms.public_ip}:8080/createmeasurements/"
    }
  }

  depends_on = [aws_ecr_repository.api-consumption]
}

resource "aws_cloudwatch_event_rule" "places_api_consumption_scheduler" {
  name                = "places-api-consumption-scheduler"
  description         = "Trigger API consumption Lambda every 5 minutes"
  schedule_expression = "rate(10 minutes)"

  tags = {
    Name = "places-api-consumption-scheduler"
  }
}

resource "aws_cloudwatch_event_target" "places_lambda_target" {
  rule      = aws_cloudwatch_event_rule.places_api_consumption_scheduler.name
  target_id = "ApiConsumptionLambdaTarget"
  arn       = aws_lambda_function.places_api_consumption.arn
}

# Lambda Permission for EventBridge
resource "aws_lambda_permission" "places_allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.places_api_consumption.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.places_api_consumption_scheduler.arn
}