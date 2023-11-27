# #!/bin/bash

# # Install open JDK
# sudo apt update -y
# sudo apt install openjdk-11-jre -y
# java -version

# # Install Jenkins

# curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
# echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
# sudo apt-get update
# sudo apt-get install jenkins -y
# sudo systemctl start jenkins
# sudo systemctl enable jenkins

# # Install AWS CLI
# sudo apt-get update
# sudo apt-get install -y unzip
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install

# # Install Docker
# sudo apt-get install -y docker.io

# # Add the current user to the docker group to run docker without sudo
# sudo usermod -aG docker $(whoami)

# # Add jeninks user to docker group
# sudo usermod -aG docker jenkins

# # Activate the new group membership for the current terminal session
# newgrp docker

# #Restart docker service
# sudo systemctl restart docker
# # Install Python 3
# sudo apt-get install -y python3 python3-pip

# # Install boto3 library for AWS SDK for Python
# sudo pip3 install boto3

# # Clean up
# rm awscliv2.zip