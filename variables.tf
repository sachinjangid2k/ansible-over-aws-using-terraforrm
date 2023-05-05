variable "aws_ami_id" {
  ## Amazon Linux 2 AMI (HVM)
  default = "ami-06e6b44dd2af20ed0"
  ## "ami-06e6b44dd2af20ed0"
}
variable "ssh_key_pair" {
  default = "D:/myproj/ansiblepem.pem"
  #default = "~/.ssh/id_rsa_ansilble_lab"
}
variable "ansible_node_count" {
  default = 2
}