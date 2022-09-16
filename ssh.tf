
resource "aws_instance" "ansible" {
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "mykey"

connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("/home/unthinkable-lap-0200/Desktop/terra/vpc/mykey")
    host = self.public_ip
  }

  provisioner "file" {
    source      = "mykey"
    destination = "/home/ubuntu/mykey"
  }
  provisioner "file" {
    source      = "host1.txt"
    destination = "/home/ubuntu/host1.txt"
  }
  provisioner "file" {
    source      = "jenkins-play.yml"
    destination = "/home/ubuntu/jenkins-play.yml"
  }
  
   provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install ansible -y",
      "sudo mkdir /etc/ansible"  ,
      "sudo chmod 400 /home/ubuntu/mykey",
      "sudo mv /home/ubuntu/host1.txt /etc/ansible/hosts",
      "ansible-playbook jenkins-play.yml ",
      "sudo rm /etc/ansible/hosts"
    ]
  }
}

