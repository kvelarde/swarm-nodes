provider "aws" {
    region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "kurtis-storage"
    key    = "terraform-swarm"
    region = "us-west-2"
  }
}

resource "aws_instance" "swarm-manager" {
  count = "${var.swarm_managers}"
  ami = "${var.swarm_ami_id}"
  instance_type = "${var.swarm_instance_type}"
  associate_public_ip_address = "true"
  tags {
    Name = "swarm-manager2"
    Owner = "kurtis"
    Role = "swarm-manager"
    Env = "sandbox"
    Project = "serenity"
    App = "docker"
  }

  subnet_id = "${var.subnet_id0}"
  vpc_security_group_ids = [
    "${var.sec_group_id}"
  ]
  key_name = "${var.key_name}"
  connection {
    user = "ubuntu"
    private_key = "${file("/keys/${var.key_name}.pem")}"
  }
  provisioner "remote-exec" {
    inline = [
      "if ${var.swarm_init}; then docker swarm init --advertise-addr ${self.private_ip}; fi",
      "if ! ${var.swarm_init}; then docker swarm join --token ${var.swarm_manager_token} --advertise-addr ${self.private_ip} ${var.swarm_manager_ip}:2377; fi"
    ]
  }
}

resource "aws_instance" "swarm-worker" {
  count = "${var.swarm_workers}"
  associate_public_ip_address = "true"
  tags {
    Name = "swarm-worker0"
    Owner = "kurtis"
    Role = "swarm-worker"
    Env = "sandbox"
    Project = "serenity"
    App = "docker"
  }
  ami = "${var.swarm_ami_id}"
  instance_type = "${var.swarm_instance_type}"
  subnet_id = "${var.subnet_id0}"
  vpc_security_group_ids = [
    "${var.sec_group_id}"
  ]
  key_name = "${var.key_name}"
  connection {
    user = "ubuntu"
    private_key = "${file("/keys/${var.key_name}.pem")}"
  }
  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token ${var.swarm_worker_token} --advertise-addr ${self.private_ip} ${var.swarm_manager_ip}:2377"
    ]
  }
}

output "swarm_manager_1_public_ip" {
  value = "${aws_instance.swarm-manager.0.public_ip}"
}

output "swarm_manager_1_private_ip" {
  value = "${aws_instance.swarm-manager.0.private_ip}"
}

output "swarm_manager_2_public_ip" {
  value = "${aws_instance.swarm-manager.1.public_ip}"
}

output "swarm_manager_2_private_ip" {
  value = "${aws_instance.swarm-manager.1.private_ip}"
}

output "swarm_manager_3_public_ip" {
  value = "${aws_instance.swarm-manager.2.public_ip}"
}

output "swarm_manager_3_private_ip" {
  value = "${aws_instance.swarm-manager.2.private_ip}"
}
