



This Terraform script creates an infrastructure on AWS for hosting a microsite with static and dynamic components. The infrastructure includes a VPC, subnets, security groups, EC2 instances, an RDS instance, an ELB, an S3 bucket, a CloudFront distribution, and a Route53 record. I have distributed the architecture in app, web and database component placed in public and private subnets


Summary of architecture:

•	AWS Provider: 1
•	VPC: 1 (main)
•	Subnets: 2 (public and private)
•	Security Groups: 2 (public and private)
•	EC2 Instances: 2 (web and app)
•	RDS Instance: 1 (postgres)
•	ELB: 1 (aws_elb.main)
•	S3 Bucket: 1 (static)
•	CloudFront Distribution: 1 (main)
•	Route53 Zone: 1 (main)
•	Route53 Record: 1 (main)



Architecture description in depth:

•	I defined an AWS provider with the region "us-east-1" in my Terraform configuration. Then, I created a VPC with a CIDR block of "10.0.0.0/16" and a tag of "main". 
•	Next, I created two subnets: one public with a CIDR block of "10.0.1.0/24", an availability zone of "us-east-1a", and a tag of "public"; and one private with a CIDR block of "10.0.2.0/24", an availability zone of "us-east-1b", and a tag of "private".

•	After that, I created two security groups: one for the public subnet that allowed incoming traffic on port 80 from any IP address, and one for the private subnet that allowed incoming traffic on port 5432 from the security group associated with the public subnet.

•	Next, I created two EC2 instances: one in the public subnet with an Ubuntu AMI, a t2.micro instance type, and a user data script that installed Apache web server; and one in the private subnet with the same AMI and instance type, and a user data script that installed Docker.

•	I also created an RDS instance with 10GB of storage, the PostgreSQL engine version 11.4, a db.t2.micro instance class, a database name of "mydb", and a username and password of "admin" and "password" respectively. It used the default parameter group for PostgreSQL 11 and skipped the final snapshot. The RDS instance was associated with the private security group and a subnet group called "mydb-subnet-group". I tagged it with the name "mydb".

•	I then created an Elastic Load Balancer with the name "my-elb" in the public subnet that listened on port 80 and performed a health check on the root URL path. It was associated with the public security group.

•	Additionally, I also created an S3 bucket called "manish-static-files" that had public read access and a website configuration that specified "index.html" as the index document and "404.html" as the error document.

•	Then i created a CloudFront distribution that used the S3 bucket as its origin, allowed GET, HEAD, and OPTIONS methods, and set a viewer protocol policy to redirect HTTP to HTTPS. It was enabled for IPv6 and used the default root object of "index.html". I also set up some geo restrictions that whitelisted the US, Canada, the UK, and Germany, and specified two domain names as aliases. 

•	Finally, I created a Route53 zone for the "manish.com" domain and created an A record that pointed to the CloudFront distribution using an alias.
