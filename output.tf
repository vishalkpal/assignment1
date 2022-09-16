output "vpc_id" {
  value = aws_vpc.Myvpc.id
}

output "public_id" {
  value = aws_subnet.public.id
}

output "private_id" {
  value = aws_subnet.private.id
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.ig.id
}

output "aws_sg" {
  value = aws_security_group.sg.id
}

output "instance_ip" {
  value = aws_instance.web.*.public_ip[0]
}

output "instance_id" {
  value =  aws_instance.web[*].id
}