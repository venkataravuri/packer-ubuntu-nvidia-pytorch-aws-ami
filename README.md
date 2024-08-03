# A Packer script for AWS AMI

A packer script that generates AWS AMI with Ubuntu, NVIDIA GPU Drivers, Python, Pytorch and more.

### Install Packer

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
```

### Create ML Optimized AWS AMI

```
packer build -var-file="variables.pkrvars.hcl" aws-ubuntu.pkr.hcl
```

