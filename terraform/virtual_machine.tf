/* Macchina virtuale EC2 per deploy applicazione */

resource "aws_instance" "devsecops-istance" {
  ami           = "ami-0230bd60aa48260c6"
  instance_type = "t2.medium"
  key_name = "jenkins"
  vpc_security_group_ids = [aws_security_group.devsecops-istance-sg.id]
  subnet_id = "${element(module.vpc.public_subnets, 0)}"
  user_data = file("configuration.sh")

  monitoring = true

  metadata_options {
    http_endpoint = disabled
    instance_metadata_tags = disabled
  }

  associate_public_ip_address = true  # Aggiunto per assegnare un IP pubblico

  tags = {
    Name = "vm-devops"
  }
}


#creazione security group
resource "aws_security_group" "devsecops-istance-sg" {
  
  vpc_id = module.vpc.vpc_id
  name="vm-devops-sg"
  description = "Security group con accesso http e ssh"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#creazione regole per security group: http (porte 80 e 8080) e ssh (porta 22)
resource "aws_security_group_rule" "devsecops-istance-inbund-http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.devsecops-istance-sg.id
}

resource "aws_security_group_rule" "devsecops-istance-inbund-http-jenkins" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.devsecops-istance-sg.id
}

resource "aws_security_group_rule" "devsecops-istance-inbund-ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.devsecops-istance-sg.id
}