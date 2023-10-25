
output "jenkins-public_ip" {
  value = "http://${aws_instance.tf-jenkins-server.public_ip}:8080"
}

output "docker-ec2-public-ip" {
  value = aws_instance.tf-docker-server.public_ip
}

