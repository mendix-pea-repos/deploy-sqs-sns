provider "aws" {
  region = "us-west-2" # change this to your preferred region
}

# Create SNS topic
resource "aws_sns_topic" "my_topic" {
  name = "my-topic"

  tags = {
    Environment = "dev"
    Name        = "my-topic"
  }
}

# Create SQS queue
resource "aws_sqs_queue" "my_queue" {
  name                       = "my-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 0
  visibility_timeout_seconds = 30

  tags = {
    Environment = "dev"
    Name        = "my-queue"
  }
}

# Create SQS queue policy to allow all actions for everyone
resource "aws_sqs_queue_policy" "allow_sqs_all" {
  queue_url = aws_sqs_queue.my_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
        "AWS": [
          "arn:aws:iam::944871421452:user/ams-sa",
          "arn:aws:iam::944871421452:root"
        ]
      },
        Action =  [
        "SQS:ChangeMessageVisibility",
        "SQS:DeleteMessage",
        "SQS:ReceiveMessage"
      ],
        Resource = aws_sqs_queue.my_queue.arn
      }
    ]
  })
}

# Create SNS topic policy to allow all actions for everyone
resource "aws_sns_topic_policy" "allow_sns_all" {
  arn    = aws_sns_topic.my_topic.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = [
        "SNS:Publish",
        "SNS:RemovePermission",
        "SNS:SetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:AddPermission",
        "SNS:Subscribe"
      ],
        Resource = aws_sns_topic.my_topic.arn
      }
    ]
  })
}

output "queue_url" {
  value = aws_sqs_queue.my_queue.id
}

output "topic_arn" {
  value = aws_sns_topic.my_topic.arn
}
