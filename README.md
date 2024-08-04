# A Packer script for AWS ML Optimized AMI

A packer script that generates AWS AMI with Ubuntu, NVIDIA GPU Drivers, Python, Pytorch and more.

### Install Packer

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
```

### Environment Settings
Create `variables.pkrvars.hcl' file with below settings,
```
region = <AWS Region>
vpc_id = <VPC ID>
subnet_id = <Subnet ID>
aws_sso_profile = <AWS SSO Profile>
distro = <Ubuntu Distribution Name> e.g., "ubuntu2404"
arch = e.g., "x86_64"
```

### Create ML Optimized AWS AMI

```
packer build -var-file="variables.pkrvars.hcl" aws-ubuntu.pkr.hcl
```

