#crete vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Application VPC "
    }   
}

#create public subnet A
resource "aws_subnet" "publicsubnetA" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
        tags = {
            Name = "Public Subnet-A"
        }    

}


#create public subnet B
resource "aws_subnet" "publicsubnetB" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
            tags = {
                Name = "Public Subnet-B"
            }   
}



#create security group for App
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
    
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



#create private App-A
resource "aws_subnet" "privateAppSubnet-A" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
    availability_zone = "us-east-1a"
            tags = {
                Name = "private App Subnet-A"
            }   
}



#create private App-B
resource "aws_subnet" "privateAppSubnet-B" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
    availability_zone = "us-east-1b"
            tags = {
                Name = "private App Subnet-B"
            }   
}

#create ec2 instance in private app subnet A
resource "aws_instance" "app_instance_A" {
  ami           = "ami-00e801948462f718a"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.privateAppSubnet-A.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
    tags = {
        Name = "App Instance A"
    }   
}   

#create ec2 instance in private app subnet B
resource "aws_instance" "app_instance_B" {
  ami           = "ami-00e801948462f718a"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.privateAppSubnet-B.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
    tags = {
        Name = "App Instance B"
    }   
}   




#create target group
resource "aws_lb_target_group" "app_tg" {
  target_type = "instance"
  name     = "TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path = "/"
    protocol = "HTTP"
  }
}   

resource "aws_lb_target_group_attachment" "app_tg_attachment_A" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_instance_A.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app_tg_attachment_B" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_instance_B.id
  port             = 80
}


