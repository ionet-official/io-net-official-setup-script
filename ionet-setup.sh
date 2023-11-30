#!/bin/bash

set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive
sudo dpkg --set-selections <<< "cloud-init hold"

# Detect if an Nvidia GPU is present
NVIDIA_PRESENT=$(lspci | grep -i nvidia || true)

# Only proceed with Nvidia-specific steps if an Nvidia device is detected
if [[ -z "$NVIDIA_PRESENT" ]]; then
    echo "No NVIDIA device detected on this system."
else
# Check if nvidia-smi is available and working
    if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
        echo "CUDA drivers already installed as nvidia-smi works."
    else

        sudo -- sh -c 'apt-get update; apt-get upgrade -y; apt-get autoremove -y; apt-get autoclean -y'
        sudo apt-get install linux-headers-$(uname -r) -y
        sudo apt-get install build-essential cmake unzip pkg-config software-properties-common -y
        sudo apt-get install libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev -y || true
        sudo apt-get install libjpeg-dev libpng-dev libtiff-dev -y || true
        sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev -y || true
        sudo apt-get install libxvidcore-dev libx264-dev -y || true
        sudo apt-get install libopenblas-dev libatlas-base-dev liblapack-dev gfortran -y || true
        sudo apt-get install libhdf5-serial-dev -y || true
        sudo apt-get install python3-dev python3-tk python-imaging-tk curl -y || true
        sudo apt-get install libgtk-3-dev -y || true
        sudo add-apt-repository -y ppa:graphics-drivers/ppa
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FCAE110B1118213C
        sudo apt update

        # Detect OS
        OS="$(uname)"
        case $OS in
            "Linux")
                # Detect Linux Distro
                if [ -f /etc/os-release ]; then
                    . /etc/os-release
                    DISTRO=$ID
                    VERSION=$VERSION_ID
                else
                    echo "Your Linux distribution is not supported."
                    exit 1
                fi
                
                # Depending on Distro
                case $DISTRO in
                    "ubuntu")
                        case $VERSION in
                            "20.04")
                                # Commands specific to Ubuntu 20.04
                                wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
                                sudo dpkg -i cuda-keyring_1.1-1_all.deb
                                sudo apt-get update
                                sudo apt-get -y install cuda
                                ;;
                            
                            "22.04")
                                # Commands specific to Ubuntu 22.04
                                wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
                                sudo dpkg -i cuda-keyring_1.1-1_all.deb
                                sudo apt-get update
                                sudo apt-get -y install cuda
                                ;;

                            *)
                                echo "This version of Ubuntu is not supported in this script."
                                exit 1
                                ;;
                        esac
                        ;;
                    
                    "debian")
                        case $VERSION in
                            "10"|"11")
                                # Commands specific to Debian 10 & 11
                                wget https://developer.download.nvidia.com/compute/cuda/repos/debian${VERSION}/x86_64/cuda-keyring_1.1-1_all.deb
                                sudo dpkg -i cuda-keyring_1.1-1_all.deb
                                sudo add-apt-repository contrib
                                sudo apt-get update
                                sudo apt-get -y install cuda
                                ;;
                            
                            *)
                                echo "This version of Debian is not supported in this script."
                                exit 1
                                ;;
                        esac
                        ;;

                    "fedora")
                        # Fedora 37 (Specifically mentioned)
                        sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora37/x86_64/cuda-fedora37.repo
                        sudo dnf clean all
                        sudo dnf -y module install nvidia-driver:latest-dkms
                        sudo dnf -y install cuda
                        ;;

                    "kylin")
                        # KylinOS 10 (Specifically mentioned)
                        sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/kylin10/x86_64/cuda-kylin10.repo
                        sudo dnf clean all
                        sudo dnf -y module install nvidia-driver:latest-dkms
                        sudo dnf -y install cuda
                        ;;
                    
                    "opensuse-tumbleweed"|"opensuse-leap")
                        # OpenSUSE
                        sudo zypper addrepo https://developer.download.nvidia.com/compute/cuda/repos/opensuse15/x86_64/cuda-opensuse15.repo
                        sudo zypper refresh
                        sudo zypper install -y cuda
                        ;;

                    "rhel"|"rocky")
                        # Red Hat Enterprise Linux and Rocky Linux
                        if [[ $VERSION -ge 7 ]] && [[ $VERSION -le 9 ]]; then
                            sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel${VERSION}/x86_64/cuda-rhel${VERSION}.repo
                            if [[ $VERSION == 7 ]]; then
                                sudo yum clean all
                                sudo yum -y install nvidia-driver-latest-dkms
                            else
                                sudo dnf clean all
                                sudo dnf -y module install nvidia-driver:latest-dkms
                            fi
                            sudo dnf -y install cuda
                        else
                            echo "This version of RHEL or Rocky Linux is not supported in this script."
                            exit 1
                        fi
                        ;;

                    "sles")
                        # SUSE Linux Enterprise Server
                        sudo zypper addrepo https://developer.download.nvidia.com/compute/cuda/repos/sles15/x86_64/cuda-sles15.repo
                        sudo zypper refresh
                        sudo zypper install -y cuda
                        ;;

                    *)
                        echo "Your Linux distribution is not supported."
                        exit 1
                        ;;
                esac
                ;;
            
            "Windows_NT")
                # For Windows Subsystem for Linux (WSL) with Ubuntu
                if grep -q Microsoft /proc/version; then
                    wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
                    sudo dpkg -i cuda-keyring_1.1-1_all.deb
                    sudo apt-get update
                    sudo apt-get -y install cuda
                else
                    echo "This bash script can't be executed on Windows directly unless using WSL with Ubuntu. For other scenarios, consider using a PowerShell script or manual installation."
                    exit 1
                fi
                ;;

            *)
                echo "Your OS is not supported."
                exit 1
                ;;
        esac

        sudo reboot
    fi
fi
# For testing purposes, this should output NVIDIA's driver version
if [[ ! -z "$NVIDIA_PRESENT" ]]; then
    nvidia-smi
fi

# Check if Docker is installed
if command -v docker &>/dev/null; then
    echo "Docker is already installed."
else
    echo "Docker is not installed. Proceeding with installations..."
    sudo apt install docker.io -y
    sudo systemctl restart docker 
    # Optionally add installation steps for Docker and nvidia-docker if you have them
fi

sudo curl -L "https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
docker-compose --version


if [[ ! -z "$NVIDIA_PRESENT" ]]; then
    if sudo docker run --gpus all nvidia/cuda:11.0.3-base-ubuntu18.04 nvidia-smi &>/dev/null; then
        echo "nvidia-docker is enabled and working. Exiting script."
    else
        echo "nvidia-docker does not seem to be enabled. Proceeding with installations..."
        distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
        curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add
        curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
        sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
        sudo systemctl restart docker 
        sudo docker run --gpus all nvidia/cuda:11.0.3-base-ubuntu18.04 nvidia-smi
    fi
fi

sudo dpkg --set-selections <<< "cloud-init install"
sudo groupadd docker || true
sudo usermod -aG docker $USER || true
newgrp docker || true
