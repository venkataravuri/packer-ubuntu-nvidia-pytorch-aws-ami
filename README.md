# A Packer script for AWS AMI

A packer script that generates AWS AMI with Ubuntu, NVIDIA GPU Drivers, Python, Pytorch and more.

```
packer build -var-file="variables.pkrvars.hcl" aws-ubuntu.pkr.hcl
```

