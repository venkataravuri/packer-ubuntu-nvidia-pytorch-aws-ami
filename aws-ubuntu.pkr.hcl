packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_sso_profile" {
  type = string
}
variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name                    = "ubuntu-nvidia-pytorch-ami-${local.timestamp}"
  instance_type               = "g5.xlarge"
  profile                     = "${var.aws_sso_profile}"
  region                      = "${var.region}"
  vpc_id                      = "${var.vpc_id}"
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = false
  ssh_interface               = "private_ip"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 256
    volume_type           = "gp3"
    delete_on_termination = true
  }
  ssh_username = "ubuntu"
}

build {
  name = "ubuntu-ml-optimized-ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    expect_disconnect = true
    inline = [
      "echo Installing NVIDIA drivers and CUDA Toolkit",
      "sudo apt-get install -y linux-headers-$(uname -r)",
      "sudo apt-key del 7fa2af80",
      "wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb",
      "sudo dpkg -i cuda-keyring_1.1-1_all.deb",
      "sudo apt-get update",
      "sudo apt-get install -y cuda-toolkit",
      "sudo apt-get install -y nvidia-gds",
      "sudo apt-get install -y nvidia-open",
      "sudo apt-get install -y nvidia-utils-560",
      "export CUDA_HOME=/usr/local/cuda",
      "export PATH=${CUDA_HOME}/bin:${PATH}",
      "export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH",
      "sudo reboot"
    ]
  }

  provisioner "shell" {
    pause_before = "20s"
    inline = [
      "echo Installing Python",
      "sudo apt-get install -y python3",
      "sudo apt-get install -y python3-pip",
      "sudo apt-get install -y python3-venv"
    ]
  }

}
