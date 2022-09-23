#!/bin/bash

function start_docker_service_debian(){
	# Start Docker Service
	echo "Starting Docker at startup | Use Ctrl^C to Exit | Will execute after 6 seconds"
	sleep 6
	sudo systemctl start docker
	echo "Enabled Docker at Startup"
}

function enable_docker_service_debian(){
	# Enable Docker at Startup
	echo "Enabling Docker at startup | Use Ctrl^C to Exit | Will execute after 6 seconds"
	sleep 6
	sudo systemctl enable docker
	echo "Enabled Docker at Startup"
}

function default_debian_execution(){
	# Remove old dependencies
	echo $1 | sudo -S apt-get remove docker docker-engine docker.io containerd runc
	echo $1 | sudo -S apt-get update
	echo $1 | sudo -S apt-get install ca-certificates curl gnupg lsb-release -y
	echo $1 | sudo -S mkdir -p /etc/apt/keyrings
}

function install_docker_engine(){
	# Install docker Engine
	echo $1 | sudo -S apt-get update
	echo $1 | sudo -S apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
}


function install_docker_debian(){
	default_debian_execution $1

	# Set GPG Keys
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	# Set Repository detail
	echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
	https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	# Install docker Engine
	install_docker_engine $1

}


function install_docker_ubuntu(){

	default_debian_execution $1

	# Set GPG Keys
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	# Set Repository detail
	echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
	https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	# Install Docker Engine
	install_docker_engine $1

}


function install_docker_kali(){

	default_debian_execution $1

	# Set GPG Keys
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	# Set Repository detail
	echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" | sudo tee /etc/apt/sources.list.d/docker.list

	# Install Docker Engine
	install_docker_engine $1

}

function install_docker_parrotSecurity(){

	# Remove previous unsupported Packages if any
	echo $1 | sudo -S apt-get remove docker.io

	# Update & Install Latest package of docker
	echo $1 | sudo -S apt-get update
	echo $1 | sudo -S apt-get install docker.io -y
}


function install_docker_rhel(){
	# Reference : https://docs.docker.com/engine/install/rhel/

	# Remove old Packages
	echo $1 | sudo -S yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc

   # Setup Repository
   echo $1 | sudo -S yum install -y yum-utils
   echo $1 | sudo -S yum-config-manager \
    --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

   # Install Docker Engine
   echo $1 | sudo -S yum -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
}



function install_docker_fedora(){
	# Reference : https://docs.docker.com/engine/install/fedora/

	# Remove old Packages
	echo $1 | sudo -S dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

   # Setup Repository
   echo $1 | sudo -S dnf -y install dnf-plugins-core
   echo $1 | sudo -S dnf config-manager \
    --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

   # Install Docker Engine
   echo $1 | sudo -S dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
}


function install_docker_centos(){
	# Reference : https://docs.docker.com/engine/install/centos/

	# Remove old Packages
	echo $1 | sudo -S yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

   # Setup Repository
   echo $1 | sudo -S yum install -y yum-utils
   echo $1 | sudo -S yum-config-manager \
    --add-repo https://download.docker.com/linux/centos/docker-ce.repo

   # Install Docker Engine
   echo $1 | sudo -S yum install -y  docker-ce docker-ce-cli containerd.io docker-compose-plugin
}


function install_docker_sles(){
	# Reference : https://docs.docker.com/engine/install/sles/

	# Remove old Packages
	echo $1 | sudo -S zypper remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  runc

   # Setup Repository
   echo $1 | sudo -S zypper addrepo https://download.docker.com/linux/sles/docker-ce.repo

   # Install Docker Engine
   echo $1 | sudo -S zypper install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

   }

echo "Release Info:"
lsb_release -a 2>/dev/null
echo ''

read -p "Choose Distribution
[1] Debian
[2] Ubuntu
[3] Kali Linux
[4] Parrot Security
[5] RHEL [Not Tested]
[6] Fedora [Not Tested]
[7] Cent OS [Not Tested]
[8] SLES [Not Tested]

>>> " dist_choice


read -sp "Enter current User password >>> " usr_pass

if [[ "$EUID" = 0 ]]; then
    echo "Running this script as root is not recommended"
    exit 1
else
    echo ""
    if echo $usr_pass | sudo -l -S 2>/dev/null;
    then 
		echo ""
	else
		echo ""
        whoami | xargs echo "Incorrect Password Provided for USER: "
        exit 1
    fi
fi

if [ $dist_choice -eq 1 ]
then
   whoami | xargs echo "Installing docker Engine for Debian | starting after 5 seconds | Use Ctrl^C to Exit
CURRENT USER: "
   sleep 5
   install_docker_debian $usr_pass

elif [ $dist_choice -eq 2 ]
then
    whoami | xargs echo "Installing docker Engine for Ubuntu | starting after 5 seconds | Use Ctrl^C to Exit
CURRENT USER: "
   sleep 5
   install_docker_ubuntu $usr_pass

elif [ $dist_choice -eq 3 ]
then
    whoami | xargs echo "Installing docker Engine for Kali Linux | starting after 5 seconds | Use Ctrl^C to Exit
CURRENT USER: "
   sleep 5
   install_docker_kali $usr_pass

elif [ $dist_choice -eq 4 ]
then
    whoami | xargs echo "Installing docker Engine for Parrot Security OS | starting after 5 seconds | Use Ctrl^C to Exit
CURRENT USER: "
   sleep 5
   install_docker_parrotSecurity $usr_pass

elif [ $dist_choice -eq 5 ]
then
    whoami | xargs echo "Installing docker Engine for RHEL | starting after 5 seconds | Use Ctrl^C to Exit
CURRENT USER: "
   sleep 5
   install_docker_rhel $usr_pass

elif [ $dist_choice -eq 6 ]
then
    whoami | xargs echo "Installing docker Engine for Fedora | starting after 5 seconds | Use Ctrl^C to Exit
CURRENT USER: "
   sleep 5
   install_docker_fedora $usr_pass

elif [ $dist_choice -eq 7 ]
then
    whoami | xargs echo "Installing docker Engine for CentOS | starting after 5 seconds | Use Ctrl^C to Exit
CURRENT USER: "
   sleep 5
   install_docker_centos $usr_pass

elif [ $dist_choice -eq 8 ]
then
    whoami | xargs echo "Installing docker Engine for SLES | starting after 5 seconds | Use Ctrl^C to Exit
CURRENT USER: "
   sleep 5
   install_docker_sles $usr_pass

else
	echo "Invalid Input Provided"
	exit 1
fi

echo ""
# Starting and Enabling Docker Services

read -p "Enable Docker Service at STARTUP (y/n) >>> " enable_service

if [ $enable_service == "y" ]
then
   enable_docker_service_debian
fi

read -p "Start Docker Service (y/n) >>> " start_service

if [ $start_service == "y" ]
then
   start_docker_service_debian
fi
