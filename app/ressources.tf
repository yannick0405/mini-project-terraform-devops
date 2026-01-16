provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["../../.secrets/credentials"]
  profile                  = "yannick"
}

# AMI Ubuntu Jammy
data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"] # On force l'architecture compatible t2.micro
  }
}

module "security_group" {
  source = "../modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "keypair" {
  source   = "../modules/keypair"
  key_name = "jenkins-key"
}

module "ec2" {
  source        = "../modules/ec2"
  ami_id        = data.aws_ami.ubuntu_jammy.id
  instance_type = "t3.micro"
  subnet_id     = module.public_subnet.subnet_id
  sg_id         = module.security_group.security_group_id
  key_name      = module.keypair.key_name
}
module "vpc" {
  source     = "../modules/vpc"
  cidr_block = "10.0.0.0/16"
}

module "public_subnet" {
  source            = "../modules/public_subnet"
  vpc_id            = module.vpc.vpc_id
  public_rt_id      = module.vpc.public_route_table_id # Attention au nom de l'output !
  igw_id            = module.vpc.igw_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}
module "ebs" {
  source            = "../modules/ebs"
  size              = 10
  availability_zone = "us-east-1a"
  instance_id       = module.ec2.instance_id
}

module "eip" {
  source      = "../modules/eip"
  instance_id = module.ec2.instance_id
}

# null_resource pour installer Jenkins via Docker Compose
resource "null_resource" "jenkins_install" {
  depends_on = [module.ec2]
  # On force une attente de 30 secondes pour laisser Ubuntu démarrer
  
  provisioner "remote-exec" {
    connection {
    type        = "ssh"
    host        = module.eip.public_ip # Utilise l'output de ton module EIP
    user        = "ubuntu"
    private_key = module.keypair.private_key_pem
    # Terraform essaiera de se connecter pendant 5 minutes avant d'abandonner
      timeout     = "5m"
  }
    inline = [
      "sudo apt update -y",
      "sudo apt install -y docker.io docker-compose",
      "sudo systemctl enable docker --now",
      "sudo usermod -aG docker ubuntu",
      "mkdir -p ~/jenkins",
      "echo 'version: \"3\"' > ~/jenkins/docker-compose.yml",
      "echo 'services:\n  jenkins:\n    image: jenkins/jenkins:lts\n    ports:\n      - \"8080:8080\"\n    volumes:\n      - ./jenkins_home:/var/jenkins_home' >> ~/jenkins/docker-compose.yml",
      "cd ~/jenkins && sudo docker-compose up -d",
      "echo 'Public IP: ${module.ec2.instance_public_ip}' > jenkins_ec2.txt"
    ]
  }
}
