This Terraform script creates an infrastructure on AWS for hosting a microsite with static and dynamic components. The infrastructure includes a VPC, subnets, security groups, EC2 instances, an RDS instance, an ELB, an S3 bucket, a CloudFront distribution, and a Route53 record. I have distributed the architecture in app, web and database component placed in public and private subnets

---

### Services used: 
AWS services:

-	VPC (Virtual Private Cloud)
-	EC2 (Elastic Compute Cloud)
-	RDS (Relational Database Service)
-	Security Group

Resources:
-	VPC
-	VPC CIDR block
-	Public Subnet
-	Private Subnet
-	Internet Gateway
-	Route Table
-	Route Table Association
-	EC2
-	Key Pair
-	Security Group
-	EC2 Instance
-	RDS
-	DB Instance
-	DB Subnet Group
-	DB Parameter Group
-	DB Security Group

---

### Summary of architecture:

#### Presentation tier: (Public subnet)
-	AWS Elastic Load Balancer (ELB)
-	AWS Security Group (to allow inbound traffic to the ELB)
-	AWS Route 53 (to associate a domain name with the ELB)
#### Application tier: (private subnet)
-	AWS EC2 instance (to run the application)
-	AWS Security Group (to allow inbound traffic to the EC2 instance)
-	AWS IAM instance profile (to grant permissions to the EC2 instance to access other AWS services)
-	AWS S3 bucket (to store application data)
#### Data tier: (private subnet)
-	AWS RDS instance (to host the database)
-	AWS Security Group (to allow inbound traffic to the RDS instance)
-	AWS Subnet Group (to specify the subnets in which the RDS instance should run)
-	AWS DB Parameter Group (to configure the database settings)

---

### Architecture description in depth:

-	First, I define the provider that I will be using in my code, which in this case is AWS. I set the region to be used based on a variable passed in.

-	Then, I create a VPC resource with a specified CIDR block and a Name tag. 

-	Next, I create subnets for the VPC. There are two types of subnets: public and private. I assign a VPC ID, a CIDR block, and an availability zone to each subnet. Public subnets have the option to map public IP addresses to instances launched in them. Each subnet also has a Name tag.

-	After that, I create security groups for both public and private subnets. The public security group allows inbound traffic on port 80 and the private security group allows inbound traffic on port 5432 from instances associated with the public security group.

-	Next, I create an EC2 instance resource with an AMI ID, instance type, and subnet ID. I assign a security group and a user data script to the instance. A root block device is also defined for the instance. In addition, I create a launch configuration resource that contains the same parameters as the EC2 instance resource.

-	Then, I create an autoscaling group resource that is associated with the launch configuration. The autoscaling group has a desired capacity of 2 instances, with a minimum of 1 and a maximum of 3. It also has a health check that is based on EC2 instances. 

-	The autoscaling group spans across all public subnets.

-	Following that, I create an RDS instance resource with a DB instance class, engine, engine version. The RDS instance is associated with the private security group and a DB subnet group.

-	After that, I create an ELB resource with a specified name, public subnets, and a security group. I set up a listener that listens on port 80 and has an HTTP protocol. The ELB also has a health check that checks the HTTP response from the instances.

-	Then, I create an S3 bucket resource with a specified name and website properties. The bucket is set to be publicly readable.

-	Finally, I create a CloudFront distribution resource that uses the S3 bucket as an origin. The default cache behavior is set up with specific allowed and cached methods, a viewer protocol policy, and TTL values. I also set up aliases for the CloudFront distribution 
