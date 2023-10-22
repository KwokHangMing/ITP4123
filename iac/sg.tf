resource "aws_security_group" "alb_sg" {
  name        = "ALB Security Group"
  description = "Allow ALB inbound traffic and outbound to Lambda"
  vpc_id      = aws_vpc.itp4124_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALB with ingress rule from anywhere."
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "ALB Security Group"
  }
}
#sqs sg and secret manager sg

resource "aws_security_group" "sqs_endpoint" {
  name        = "SQS Endpoint Security Group"
  description = "Allow traffic to SQS endpoint"
  vpc_id      = aws_vpc.itp4124_vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "SQS Endpoint Security Group"
  }
}

resource "aws_security_group" "secrets_manager_endpoint" {
  name        = "Secrets Manager Endpoint Security Group"
  description = "Allow traffic to Secrets Manager endpoint"
  vpc_id      = aws_vpc.itp4124_vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "Secrets Manager Endpoint Security Group"
  }
}

#lambda sg

resource "aws_security_group" "lambda_sg" {
  name        = "Web Lambda Security Group"
  description = "Allow lambda inbound traffic"
  vpc_id      = aws_vpc.itp4124_vpc.id
  tags = {
    Name = "Web Lambda Security Group"
  }
}

resource "aws_security_group_rule" "alb_to_Lambda" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.lambda_sg.id
  description              = "Lambda with ingress rule from ALB."
}

resource "aws_security_group_rule" "lambda_to_db" {
  type                     = "egress"
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.db_sg.id
  description              = "Lambda to Database"
}
resource "aws_security_group_rule" "lambda_to_sqs" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.sqs_endpoint.id
  description              = "Lambda to SQS Endpoint"
}

resource "aws_security_group_rule" "lambda_to_secret_manager" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.secrets_manager_endpoint.id
  description              = "Lambda to Secrets Manager Endpoint"
}

resource "aws_security_group_rule" "lambda_to_dynamodb" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_sg.id
  prefix_list_ids   = [aws_vpc_endpoint.dynamodb.prefix_list_id]
  description       = "Lambda to DynamoDB"
}

resource "aws_security_group_rule" "lambda_to_s3" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.lambda_sg.id
  prefix_list_ids   = [aws_vpc_endpoint.s3_vpc_endpoint.prefix_list_id]
  description       = "Lambda to S3"
}


#database sg
resource "aws_security_group" "db_sg" {
  name        = "Database Security Group"
  description = "Database with ingress rule from Lambda."
  vpc_id      = aws_vpc.itp4124_vpc.id

  ingress {
    description     = "TLS from VPC"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "Database Security Group"
  }
}


#endpoints
resource "aws_vpc_endpoint" "sqs_vpc_endpoint" {
  vpc_id            = aws_vpc.itp4124_vpc.id
  service_name      = "com.amazonaws.us-east-1.sqs"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.sqs_endpoint.id]
}

resource "aws_vpc_endpoint" "secretMgn_vpc_endpoint" {
  vpc_id            = aws_vpc.itp4124_vpc.id
  service_name      = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.secrets_manager_endpoint.id]
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.itp4124_vpc.id
  service_name      = "com.amazonaws.us-east-1.dynamodb"
  vpc_endpoint_type = "Gateway"
}

