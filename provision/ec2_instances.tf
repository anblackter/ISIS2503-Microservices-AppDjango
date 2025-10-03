resource "aws_instance" "variables_db" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  primary_network_interface {
    network_interface_id = aws_network_interface.variables_db_ni.id
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/ec2-db.sh", {
    docker_compose_content = file("${path.module}/docker-compose/variables-db/docker-compose.yml")
  })

  key_name = var.ssh_key_name

  tags = {
    Name = "VariablesDBEC2Instance"
  }
}

resource "aws_instance" "measurements_db" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  primary_network_interface {
    network_interface_id = aws_network_interface.measurements_db_ni.id
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/ec2-db.sh", {
    docker_compose_content = file("${path.module}/docker-compose/measurements-db/docker-compose.yml")
  })

  key_name = var.ssh_key_name

  tags = {
    Name = "MeasurementsDBEC2Instance"
  }
}

resource "aws_instance" "variables_ms" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  primary_network_interface {
    network_interface_id = aws_network_interface.variables_ms_ni.id
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    delete_on_termination = true
  }

  user_data = filebase64("${path.module}/ec2-variables-ms.sh")

  key_name = var.ssh_key_name

  tags = {
    Name = "VariablesMSEC2Instance"
  }
}


resource "aws_instance" "measurements_ms" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  primary_network_interface {
    network_interface_id = aws_network_interface.measurements_ms_ni.id
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    delete_on_termination = true
  }

  user_data = filebase64("${path.module}/ec2-measurements-ms.sh")

  key_name = var.ssh_key_name

  tags = {
    Name = "MeasurementsMSEC2Instance"
  }
}

resource "aws_instance" "kong" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  primary_network_interface {
    network_interface_id = aws_network_interface.kong_ni.id
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    delete_on_termination = true
  }

  user_data = filebase64("${path.module}/ec2-kong.sh")

  key_name = var.ssh_key_name

  tags = {
    Name = "KongEC2Instance"
  }
}

# Fetch the latest Ubuntu AMI ID for the specified region
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}