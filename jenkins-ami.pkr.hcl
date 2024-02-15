packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "aws_account_id" {
  type    = string
  default = "458266182191"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "ghactions"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}



// Define Source
source "amazon-ebs" "ubuntu" {
  ami_name      = "jenkins-ami-{{timestamp}}"
  instance_type = "t2.micro"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  ssh_username = "ubuntu"
  ami_users    = [var.aws_account_id]
  profile      = var.profile
}

// Include Build Definition
build {
  sources = ["source.amazon-ebs.ubuntu"]

  // Provisioners to install Jenkins and dependencies
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "file" {
    source      = "jenkins_plugins.txt"
    destination = "jenkins_plugins.txt"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh"
    ]
  }

}
