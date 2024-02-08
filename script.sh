#!/bin/bash

set -e

echo ******************* Updating/Upgrading package lists *******************
sudo apt-get update
sudo apt-get upgrade -y


echo ******************* Setup Java*******************
sudo add-apt-repository ppa:linuxuprising/java -y

sudo apt-get update

echo oracle-java17-installer shared/accepted-oracle-license-v1-3 select true | sudo debconf-set-selections
sudo apt-get install oracle-java17-installer -y
sudo apt-get install oracle-java17-set-default -y

echo ******************* Jenkins Setup *******************
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install -y jenkins

echo ******************* Setup Docker *******************
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -a -G docker jenkins

echo ******************* Install node *******************
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node # "node" is an alias for the latest version
nvm install-latest-npm

echo ******************* Setup Nginx *******************
sudo apt-get install -y nginx

sudo ufw allow 'Nginx Full'

sudo systemctl enable jenkins
sudo systemctl start jenkins
