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
    pause_before = "20s"
    inline = [
      "echo Install gcc",
      "sudo apt-get install -y gcc"
    ]
  }

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
      "export PATH=$${CUDA_HOME}/bin:$${PATH}",
      "export LD_LIBRARY_PATH=$${CUDA_HOME}/lib64:$$LD_LIBRARY_PATH",
      "sudo reboot"
    ]
  }

  provisioner "shell" {
    pause_before = "20s"
    inline = [
      "echo Adding Python repo to apt",
      "sudo add-apt-repository -y ppa:deadsnakes/ppa"
    ]
  }

  provisioner "shell" {
    pause_before = "20s"
    inline = [
      "echo Download KITTI dataset",
      "sudo mkdir /data",
      "sudo mkdir /data/kitti",
      "sudo apt-get install -y unzip",
      "echo Download left color images of object data set - 12 GB",
      "wget -q https://s3.eu-central-1.amazonaws.com/avg-kitti/data_object_image_2.zip",
      "sudo unzip -q -o data_object_image_2.zip -d /data/kitti/",
      "echo Download Velodyne point clouds, if you want to use laser information = 29 GB",
      "wget -q https://s3.eu-central-1.amazonaws.com/avg-kitti/data_object_velodyne.zip",
      "sudo unzip -q -o data_object_velodyne.zip -d /data/kitti/",
      "echo Download camera calibration matrices of object data set - 16 MB",
      "wget -q https://s3.eu-central-1.amazonaws.com/avg-kitti/data_object_calib.zip",
      "sudo unzip -q -o data_object_calib.zip -d /data/kitti/",
      "echo Download training labels of object data set - 5 MB",
      "wget -q https://s3.eu-central-1.amazonaws.com/avg-kitti/data_object_label_2.zip",
      "sudo unzip -q -o data_object_label_2.zip -d /data/kitti/",
    ]
  }

}

sudo apt-get remove --auto-remove python3-pip

sudo apt-get remove --auto-remove python3
