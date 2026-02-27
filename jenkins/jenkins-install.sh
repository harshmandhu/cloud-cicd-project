# jenkins/jenkins-install.sh
#!/bin/bash
set -ex

# Update system
yum update -y

# Install Java 17 (Jenkins requirement)
amazon-linux-extras install java-openjdk17 -y 2>/dev/null || \
  yum install java-17-amazon-corretto -y

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo \
  https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install jenkins -y

# Install Docker
yum install docker -y
systemctl start docker && systemctl enable docker
usermod -aG docker jenkins
usermod -aG docker ec2-user

# Install Git
yum install git -y

# Start Jenkins
systemctl start jenkins && systemctl enable jenkins

# Install AWS CLI v2
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip
unzip awscliv2.zip && ./aws/install

echo 'Jenkins setup complete!'