#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
fi


# Function to install Docker
install_docker() {
    if [[ -f /etc/lsb-release ]]; then
        # Install Docker on Ubuntu
        sudo apt update -y
        sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt update -y
        sudo apt install docker-ce -y
        sudo apt update
        sudo apt install docker.io -y
        systemctl enable docker && systemctl start docker
    elif [[ -f /etc/redhat-release ]]; then
        # Install Docker on CentOS
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        systemctl enable docker && systemctl start docker
    fi
    echo "Docker has been installed."
}

# Function to install Jenkins
install_jenkins() {
    if [[ -f /etc/lsb-release ]]; then
        sudo apt update -y
        sudo apt install -y openjdk-11-jdk wget gnupg
        wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
        sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
        sudo apt update -y && apt install -y jenkins
        systemctl enable jenkins && systemctl start jenkins
        sudo ufw allow 8080
        sudo ufw enable
    elif [[ -f /etc/redhat-release ]]; then
        sudo yum install -y java-11-openjdk wget
        wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        sudo yum install -y jenkins
        systemctl enable jenkins && systemctl start jenkins
    fi
    echo "Jenkins has been installed."
}

# Function to install Ansible
install_ansible() {
    if [[ -f /etc/lsb-release ]]; then
        sudo apt update -y && apt install -y ansible
    elif [[ -f /etc/redhat-release ]]; then
        sudo yum install -y epel-release
        sudo yum install -y ansible
    fi
    echo "Ansible has been installed."
}

# Function to install GitLab
install_gitlab() {
    if [[ -f /etc/lsb-release ]]; then
        sudo apt update -y
        sudo apt install -y ca-certificates curl openssh-server tzdata perl postfix
        curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash
        sudo apt install -y gitlab-ce
    elif [[ -f /etc/redhat-release ]]; then
        sudo yum update -y
        curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | bash
        sudo yum install -y gitlab-ce
    fi
    echo "GitLab has been installed."
}

# Display menu
echo "Choose the software you want to install:"
echo "1) Docker"
echo "2) Jenkins"
echo "3) Ansible"
echo "4) GitLab"
echo "5) Exit"

read -p "Enter your choice: " choice

case $choice in
    1)
        install_docker
        ;;
    2)
        install_jenkins
        ;;
    3)
        install_ansible
        ;;
    4)
        install_gitlab
        ;;
    5)
        echo "Exiting script."
        exit 0
        ;;
    *)
        echo "Invalid choice!"
        ;;
esac

