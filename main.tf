resource "aws_security_group" "test_server_sg" {
  name_prefix = "test-server-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this for better security
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test_server" {
  ami           = "ami-0b74f796d330ab49c"
  instance_type = "t2.micro"
  key_name      = "testkey"
  vpc_security_group_ids = [aws_security_group.test_server_sg.id]

  user_data = file("setup.sh")

  tags = {
    Name = "ExampleWebAppServer"
  }
}

resource "aws_ebs_volume" "test_server_ebs" {
  availability_zone = aws_instance.test_server.availability_zone
  size             = 2

  tags = {
    Name = "ExampleWebAppServerEBS"
  }
}

resource "aws_volume_attachment" "test_server_attachment" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.test_server_ebs.id
  instance_id = aws_instance.test_server.id
}