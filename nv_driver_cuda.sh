#!/bin/bash

## NVIDIA GPU driver/CUDA install script for Ubuntu 20.04/22.04/24.04 ##

YELLOW="\033[1;33m"
RED="\033[0;31m"
GREEN="\033[0;32m"
ENDCOLOR="\033[0m"

if [[ $USER != root ]]; then
    echo -e "${RED}Error: must be run with sudo${ENDCOLOR}"
    echo -e "${YELLOW}Exiting...${ENDCOLOR}"
    exit 1
fi

UBUNTU_VER=$(awk -F= '/^VERSION_ID/{print $2}' /etc/os-release | tr -d '"')
IS_NVGPU=$(lspci | grep NVIDIA >/dev/null); IS_NVGPU=$?
IS_NOMODESET=$(grep -q nomodeset /etc/default/grub); IS_NOMODESET=$?
CHECK_LAPTOP=$(ls /proc/acpi/button/lid 2>&1 >/dev/null); CHECK_LAPTOP=$?
CHECK_LAPTOP2=$(dmidecode -t chassis | grep Notebook >/dev/null); CHECK_LAPTOP2=$?
CHECK_LAPTOP3=$(dmidecode -t chassis | grep Convertible >/dev/null); CHECK_LAPTOP3=$?
SB_STATE=$(mokutil --sb-state | grep enabled >/dev/null); SB_STATE=$?
IS_CUDA_KEYRING=$(dpkg -l | grep cuda-keyring >/dev/null); IS_CUDA_KEYRING=$?

function nv_cuda () 
{
while true; do
echo -e $YELLOW"Please choose what to install. E|e|Exit for exit"$ENDCOLOR
read -p "[1] Latest CUDA toolkit and NVIDIA GPU driver
[2] Latest NVIDIA GPU driver only
[E] Exit
Your choice: " -a array 
for choice in "${array[@]}"; do
case $choice in
[1])
echo -e $YELLOW"Verifying CUDA tookit repo, please wait..."$ENDCOLOR
sleep 1
if [[ $UBUNTU_VER != "20.04" && $UBUNTU_VER != "22.04" && $UBUNTU_VER != "24.04" ]]; then
    echo -e $RED"Unsupported Ubuntu version (must be 20.04/22.04/24.04 LTS)"$ENDCOLOR
    echo -e $RED"Exiting..."$ENDCOLOR
    exit 1
elif [[ $IS_CUDA_KEYRING != 0 && $UBUNTU_VER = "20.04" ]]; then
    wget --no-check-certificate -P /opt/ https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i /opt/cuda-keyring_1.1-1_all.deb
    apt update
    rm -rf /opt/cuda-keyring_1.1-1_all.deb
elif [[ $IS_CUDA_KEYRING != 0 && $UBUNTU_VER = "22.04" ]]; then
    wget --no-check-certificate -P /opt/ https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i /opt/cuda-keyring_1.1-1_all.deb
    apt update
    rm -rf /opt/cuda-keyring_1.1-1_all.deb
elif [[ $IS_CUDA_KEYRING != 0 && $UBUNTU_VER = "24.04" ]]; then
    wget -q -P /opt/ https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i /opt/cuda-keyring_1.1-1_all.deb
    apt update
    rm -rf /opt/cuda-keyring_1.1-1_all.deb
fi
echo -e $YELLOW"Installing CUDA toolkit and NVIDIA driver, please wait..."$ENDCOLOR
sleep 1 
apt -y install cuda-toolkit $(nvidia-detector) $(nvidia-detector | sed 's/driver/dkms/g') nvidia-prime
if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
    prime-select on-demand
fi
echo -e $GREEN"Done! Please reboot your computer."$ENDCOLOR
sleep 1
exit 0
;;
[2])
echo -e $YELLOW"Installing latest NVIDIA driver, please wait..."$ENDCOLOR
sleep 1
apt -y install $(nvidia-detector) $(nvidia-detector | sed 's/driver/dkms/g') nvidia-prime
if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
    prime-select on-demand
fi
echo -e $YELLOW"Done! Please reboot your computer."$ENDCOLOR
sleep 1
exit 0
;;
[Ee]) echo -e $YELLOW"Exiting..."$ENDCOLOR
exit 0
;;
*)
echo -e $RED"Invalid entry. Please retry or [E]Exit"$ENDCOLOR
;;
esac
done
done
}


if [[ $IS_NOMODESET = 0 ]];then
sed -i 's/ nomodeset//g' /etc/default/grub
update-grub >/dev/null 2>&1
fi

if [[ $SB_STATE = 0 ]]; then
mokutil --timeout 1000
fi

if [[ $UBUNTU_VER > "18.04" && $IS_NVGPU = 0 ]]; then
service systemd-resolved restart
nv_cuda
elif [[ $UBUNTU_VER = "18.04" ]]; then
echo -e $YELLOW"This OS version is no longer supported, please update to at least Ubuntu 20.04. Exiting..."$ENDCOLOR
exit 1
elif
[[ $IS_NVGPU != 0 ]]; then
echo -e $YELLOW"This computer does not have an NVIDIA GPU. Driver is not required. Exiting..."$ENDCOLOR
exit 1
fi