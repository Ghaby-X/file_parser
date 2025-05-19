terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# creation of s3 bucket
resource "aws_s3_bucket" "photo_bucket" {
  bucket        = "photo-bucket-${random_id.bucket_suffix.hex}"
  force_destroy = true


  tags = {
    Name = "image_upload_bucket"
  }
}

# configure s3 notification on image upload
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.photo_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.photo_handler.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.photo_handler.arn
    events              = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".png"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}



resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}



resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.photo_metadata.arn
      },
      {
        Action = [
          "s3:GetObject"
        ],
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.photo_bucket.arn}/*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })

}

# define lambda resource
resource "aws_lambda_function" "photo_handler" {
  filename         = "lambda_function_payload.zip"
  function_name    = "PhotoMetaDataParser"
  role             = aws_iam_role.lambda_exec_role.arn
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  handler          = "lambda_function.lambda_handler" 
  runtime          = "python3.12"


  environment {
    variables = {
      "DYNAMODB_TABLE" = aws_dynamodb_table.photo_metadata.name
    }
  }
}

# allow lambda and s3_bucket
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.photo_handler.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.photo_bucket.arn
}



resource "aws_dynamodb_table" "photo_metadata" {
  name         = "PhotoMetadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "file_name"

  attribute {
    name = "file_name"
    type = "S"
  }


  tags = {
    Name = "Photo Metadata Table"
  }
}
