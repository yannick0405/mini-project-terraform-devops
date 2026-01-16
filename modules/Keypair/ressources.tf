# 1. La clé privée (TLS)
resource "tls_private_key" "main" { # Vérifie que c'est bien "main" ici
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. La ressource AWS
resource "aws_key_pair" "deployer" { # Vérifie que c'est bien "deployer" ici
  key_name   = var.key_name
  public_key = tls_private_key.main.public_key_openssh
}

# 3. Le fichier local (optionnel si tu passes par l'output private_key_pem)
resource "local_file" "ssh_key" {
  filename        = "${path.module}/../../.secrets/${var.key_name}.pem"
  content         = tls_private_key.main.private_key_pem
  file_permission = "0600"
}
