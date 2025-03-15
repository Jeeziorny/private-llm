resource "aws_instance" "test_server" {
  ami           = "ami-0b74f796d330ab49c"
  instance_type = "t2.micro"

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