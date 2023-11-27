
resource "aws_security_group" "allow_ssh" {
  name        = "${var.name}-allow_ssh"
  description = "Allow ssh inbound traffic"
  ingress {
    description      = "keerthik"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${data.http.myip.body}/32"]
  }
  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "jenkins"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

# Create EC2 Instance
resource "aws_instance" "demo-server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "kirik"
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
#   subnet_id                   = data.aws_subnet.private.id
  associate_public_ip_address = true
  source_dest_check           = false
  # user_data = file("${path.module}/userdata.sh")

  # root disk
  root_block_device {
    volume_size           = 30
    volume_type           = "standard"
    delete_on_termination = true
    encrypted             = true
  }
  tags = {
    Name = "${lower(var.name)}-test-machine"
  }
  # extra disk
#   ebs_block_device {
#     device_name           = "/dev/xvda"
#     volume_size           = var.windows_data_volume_size
#     volume_type           = var.windows_data_volume_type
#     encrypted             = true
#     delete_on_termination = true
#   }
  
}

# Provision Jenkins using remote-exec after the EC2 instance is created
resource "null_resource" "jenkins_provisioner" {
  depends_on = [aws_instance.demo-server]
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install openjdk-11-jre -y",
      "java -version",
      "curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null",
      "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install jenkins -y",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",

      # Install Docker
      "sudo apt-get install -y docker.io",

      # Add the current user to the docker group to run docker without sudo
      "sudo usermod -aG docker $(whoami)",

      # Add jeninks user to docker group
      "sudo usermod -aG docker jenkins",

      # Activate the new group membership for the current terminal session
      "newgrp docker",

      #Restart docker service
      "sudo systemctl restart docker"
    ]
  }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("C:\\Users\\keerthik.shenoy\\Downloads\\kirik.pem")
    host     = aws_instance.demo-server.public_ip
    timeout = "2m"
  }
}

resource "null_resource" "cleanup" {
  triggers = {
    instance_id = aws_instance.demo-server.id
  }

  provisioner "local-exec" {
    command = "echo Cleanup completed on $(date)"
  }
}


