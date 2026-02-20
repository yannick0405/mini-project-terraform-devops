provider "aws" {
  region                   = var.region
  shared_credentials_files = [var.shared_credentials_file]
  profile                  = var.aws_profile
}

data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "vpc" {
  source     = "../modules/vpc"
  cidr_block = var.vpc_cidr
}

module "public_subnet" {
  source            = "../modules/public_subnet"
  vpc_id            = module.vpc.vpc_id
  public_rt_id      = module.vpc.public_route_table_id
  igw_id            = module.vpc.igw_id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone
}

module "security_group" {
  source = "../modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "keypair" {
  source   = "../modules/Keypair"
  key_name = var.key_name
}

module "ec2" {
  source           = "../modules/ec2"
  ami_id           = data.aws_ami.ubuntu_jammy.id
  instance_type    = var.instance_type
  subnet_id        = module.public_subnet.subnet_id
  sg_id            = module.security_group.security_group_id
  key_name         = module.keypair.key_name
  instance_name    = var.instance_name
  root_volume_size = var.root_volume_size
}

module "ebs" {
  source            = "../modules/ebs"
  size              = var.ebs_size
  availability_zone = var.availability_zone
  instance_id       = module.ec2.instance_id
}

module "eip" {
  source      = "../modules/eip"
  instance_id = module.ec2.instance_id
}

resource "null_resource" "jenkins_install" {
  depends_on = [module.ec2, module.eip]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = module.eip.public_ip
      user        = "ubuntu"
      private_key = module.keypair.private_key_pem
      timeout     = "10m"
    }
inline = [
  # Attendre cloud-init
  "sudo cloud-init status --wait || true",

  # Attendre les verrous apt/dpkg
  "while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do echo 'Waiting for dpkg lock...'; sleep 3; done",
  "while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do echo 'Waiting for apt lists lock...'; sleep 3; done",
  "while sudo fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do echo 'Waiting for apt archives lock...'; sleep 3; done",

  # Prérequis
  "sudo apt-get update -y",
  "sudo apt-get install -y ca-certificates curl gnupg",

  # Ajouter la clé + repo Docker officiel (Ubuntu Jammy)
  "sudo install -m 0755 -d /etc/apt/keyrings",
  "sudo rm -f /etc/apt/keyrings/docker.gpg",
  "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
  "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
  "echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable' | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null",

  # Installer Docker + compose plugin
  "sudo apt-get update -y",
  "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
  "sudo systemctl enable --now docker",

  # Vérif docker
  "sudo docker --version",
  "sudo docker compose version",

  # Préparer Jenkins
  "sudo mkdir -p /home/ubuntu/jenkins/jenkins_home",
  "sudo chown -R 1000:1000 /home/ubuntu/jenkins/jenkins_home",

  # Créer docker-compose.yml
  "sudo tee /home/ubuntu/jenkins/docker-compose.yml >/dev/null <<'EOF'\nversion: '3'\nservices:\n  jenkins:\n    image: jenkins/jenkins:lts\n    container_name: jenkins\n    restart: always\n    ports:\n      - '8080:8080'\n    volumes:\n      - ./jenkins_home:/var/jenkins_home\nEOF",

  # Lancer Jenkins
  "cd /home/ubuntu/jenkins && sudo docker compose up -d",

  # Check local Jenkins
  "sleep 10",
  "curl -fsS http://localhost:8080 >/dev/null",

  # Debug
  "sudo docker ps --filter name=jenkins --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
]
  }
}

resource "local_file" "jenkins_ec2_txt" {
  filename = "${path.module}/jenkins_ec2.txt"
  content  = <<EOT
Jenkins server metadata
Public IP: ${module.eip.public_ip}
Public DNS: ${module.ec2.instance_public_dns}
Jenkins URL: http://${module.eip.public_ip}:8080
EOT

  depends_on = [null_resource.jenkins_install]
}
