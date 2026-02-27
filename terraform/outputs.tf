# terraform/outputs.tf
output "jenkins_public_ip" { value = aws_instance.jenkins.public_ip }
output "ecr_repo_url"      { value = aws_ecr_repository.app.repository_url }