#!/bin/bash

# This script is used to setup a Jenkins server on an Ubuntu machine

# The script will:
# 1. Update and upgrade the package lists
# 2. Install Java 17
# 3. Install Jenkins
# 4. Install Jenkins plugins
# 5. Install Docker
# 6. Install Node.js
# 7. Install Nginx
# 8. Install kubectl
# 9. Install Helm
# 10. Install gcloud sdk

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

echo ******************* Setup Jenkins plugins *******************
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.13/jenkins-plugin-manager-2.12.13.jar

cat << 'EOF' > jenkins_plugins.sh
#!/bin/bash
while IFS= read -r plugin
do
    echo "Installing plugin: $plugin..."
    sudo java -jar jenkins-plugin-manager-2.12.13.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins --plugins "$plugin"
done < /home/ubuntu/jenkins_plugins.txt
EOF

chmod +x jenkins_plugins.sh

./jenkins_plugins.sh

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

sudo systemctl enable docker
sudo systemctl start docker

echo ******************* Install node *******************
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install --lts
node -v npm -v

sudo apt-get update

npm install -g semantic-release
npm install -g @semantic-release/git
npm install -g @semantic-release/exec
npm install -g conventional-changelog-conventionalcommits
npm install -g npm-cli-login

echo ******************* Setup Nginx *******************
sudo apt-get install -y nginx

sudo ufw allow 'Nginx Full'

sudo systemctl enable jenkins
sudo systemctl start jenkins

echo ******************* Setup kubectl *******************
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl

echo ******************* Setup Helm *******************
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm -y

sudo apt-get install make -y

echo ******************* Setup gcloud sdk *******************
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

sudo apt-get update && sudo apt-get install -y google-cloud-sdk

