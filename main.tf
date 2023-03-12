# Define provider
provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}

# Create subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr_blocks)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.public_subnet_availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-${count.index+1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr_blocks)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.private_subnet_availability_zones[count.index]
  tags = {
    Name = "private-${count.index+1}"
  }
}

# Create security groups
resource "aws_security_group" "public" {
  name_prefix = "public"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  name_prefix = "private"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.public.id]
  }
}

# Create EC2 instances
resource "aws_instance" "web" {
  ami = var.web_ami
  instance_type = var.web_instance_type
  subnet_id = aws_subnet.public[0].id
  security_groups = [aws_security_group.public.id]
  user_data = var.web_user_data

  # Add launch configuration for the ASG
  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = 10
    delete_on_termination = true
    volume_type = "gp2"
  }
}

# Create launch configuration
resource "aws_launch_configuration" "web" {
  name = "web-launch-config"
  image_id = var.web_ami
  instance_type = var.web_instance_type
  security_groups = [aws_security_group.public.id]
  user_data = var.web_user_data
  root_block_device {
    volume_size = 10
    delete_on_termination = true
    volume_type = "gp2"
  }
}

# Create ASG
resource "aws_autoscaling_group" "web" {
  name = "web-asg"
  launch_configuration = aws_launch_configuration.web.name
  vpc_zone_identifier = flatten([aws_subnet.public.*.id])
  min_size = 1
  max_size = 3
  desired_capacity = 2
  health_check_type = "EC2"
  health_check_grace_period = 300


  lifecycle {
    create_before_destroy = true
  }
}

# Create RDS instance
resource "aws_db_instance" "postgres" {
  allocated_storage = 10
  engine = "postgres"
  engine_version = "11.4"
  instance_class = "db.t2.micro"
  db_name = "mydb"
  username = "admin"
  password = "password"
  parameter_group_name = "default.postgres11"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.private.id]
  db_subnet_group_name = "mydb-subnet-group"

  tags = {
    Name = "mydb"
  }
}

# Create ELB
resource "aws_elb" "main" {
  name = "my-elb"
  subnets = aws_subnet.public.*.id
  security_groups = [aws_security_group.public.id]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:80/"
  }
}

# Create S3 bucket for static files
resource "aws_s3_bucket" "static" {
  bucket = "manish-static-files"
  acl = "public-read"
  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

# Create CloudFront distribution
resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id = "S3-manish-static-files"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3-manish-static-files"
    
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"
  price_class = "PriceClass_100"
  aliases = ["www.manish.com", "manish.com"]
  
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

#Create Route53 record

resource "aws_route53_zone" "main" {
name = "manish.com"
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.main.id
  name = "manish.com"
  type = "A"
  alias {
    name = aws_cloudfront_distribution.main.domain_name
    zone_id = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }
}

