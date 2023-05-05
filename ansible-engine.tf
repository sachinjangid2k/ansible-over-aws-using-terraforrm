resource "aws_instance" "ansible-engine" {
  ami           = var.aws_ami_id
  instance_type = "t2.micro"
  key_name = "ansiblepem"
  security_groups = ["ansible-sg"]
  //security_groups = "launch-wizard-1"
  user_data       = file("user-data-ansible-engine.sh")
  
  # Create inventory and ansible.cfg on ansible-engine
  provisioner "remote-exec" {
    inline = [
      "echo '[ansible]' >> /home/ec2-user/inventory",
      "echo 'ansible-engine ansible_host=${aws_instance.ansible-engine.private_dns} ansible_connection=local' >> /home/ec2-user/inventory",
      "echo '[nodes]' >> /home/ec2-user/inventory",
      "echo 'node1 ansible_host=${aws_instance.ansible-nodes[0].private_dns}' >> /home/ec2-user/inventory",
      "echo 'node2 ansible_host=${aws_instance.ansible-nodes[1].private_dns}' >> /home/ec2-user/inventory",
      "echo '' >> /home/ec2-user/inventory",
      "echo '[all:vars]' >> /home/ec2-user/inventory",
      "echo 'ansible_user=devops' >> /home/ec2-user/inventory",
      "echo 'ansible_password=devops' >> /home/ec2-user/inventory",
      "echo 'ansible_connection=ssh' >> /home/ec2-user/inventory",
      "echo '#ansible_python_interpreter=/usr/bin/python3' >> /home/ec2-user/inventory",
      "echo 'ansible_ssh_private_key_file=/home/devops/.ssh/id_rsa' >> /home/ec2-user/inventory",
      "echo \"ansible_ssh_extra_args=' -o StrictHostKeyChecking=no -o PreferredAuthentications=password '\" >> /home/ec2-user/inventory",
      "echo '[defaults]' >> /home/ec2-user/ansible.cfg",
      "echo 'inventory = ./inventory' >> /home/ec2-user/ansible.cfg",
      "echo 'host_key_checking = False' >> /home/ec2-user/ansible.cfg",
      "echo 'remote_user = devops' >> /home/ec2-user/ansible.cfg",
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))
      # user        = "devops"
      # password    = "devops"
      host        = self.public_ip
      agent       = false
    }
  }
  provisioner "file" {
    source      = "engine-config.yaml"
    destination = "/home/ec2-user/engine-config.yaml"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))
      host        = self.public_ip
    }
  }
  provisioner "file" {
    source      = "index.php"
    destination = "/home/ec2-user/index.php"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))
      host        = self.public_ip
    }
  }

  # Execute Ansible Playbook
  provisioner "remote-exec" {
    inline = [
      "sleep 120; ansible-playbook engine-config.yaml"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))
      host        = self.public_ip
    }
  }

  tags = {
    Name = "ansible task"
  }
}
