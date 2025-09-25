#!/bin/bash

if [ ! -z `sudo which apt | grep "/apt"` ]; then
	sudo apt -y update	
	sudo apt -y install git wget
elif [ -z `sudo which yum | grep "/yum"` ]; then
	yum update 
	yum install -y wget git 
fi

is_ubuntu=`awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release | egrep Ubuntu -i`
is_centos=`awk -F '=' '/PRETTY_NAME/ { print $2 }' /etc/os-release | egrep CentOS -i`

if [ ! -z "$is_ubuntu" ]; then
	is_docker_exist=`dpkg -l | grep docker -i`
elif [ ! -z "$is_centos" ]; then
	is_docker_exist=`rpm -qa | grep docker`
else
	echo "Error: Current Linux release version is not supported, please use either centos or ubuntu. "
	exit
fi

if [ ! -z "$is_docker_exist" ]; then
	echo "Warning: docker already exists. "
fi

function ubuntu_install()
{
	#Install docker
	sudo apt-get -y update
	sudo apt-get remove docker docker-engine docker.io containerd runc
	sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common  git vim 
	
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo \
		"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get -y update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
	
	sudo systemctl enable docker.service
	sudo systemctl start docker
	
	is_docker_success=`sudo docker run hello-world | grep -i "Hello from Docker"`
	if [ -z "$is_docker_success" ]; then
		echo "Error: Docker installation Failed."
		exit
	fi
	echo "Docker has been installed successfully."
}

function centos_install()
{
	#Install docker
	sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
	sudo yum install -y yum-utils device-mapper-persistent-data lvm2 git vim 
	sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	sudo yum -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
	sudo systemctl enable docker.service
	sudo systemctl start docker
	
	is_docker_success=`sudo docker run hello-world | grep -i "Hello from Docker"`
	if [ -z "$is_docker_success" ]; then
		echo "Error: Docker installation Failed."
		exit
	fi
	echo "Docker has been installed successfully."
}

if [ ! -z "$is_ubuntu" ]; then
	ubuntu_install
elif [ ! -z "$is_centos" ]; then
	centos_install
fi

docker compose version
echo "Docker compose has been installed successfully..."
