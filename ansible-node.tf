resource "aws_instance" "ansible-nodes" {
  ami             = var.aws_ami_id #"ami-0cd31be676780afa7"
  instance_type   = "t2.micro"
  key_name        = "ansiblepem"
  count           = var.ansible_node_count
  security_groups = ["ansible-sg"]
  user_data       = file("user-data-ansible-nodes.sh")
  tags = {
    Name = "ansible-node-${count.index + 1}"
  }
}
