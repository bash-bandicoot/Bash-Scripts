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
read -rp "[1] Install NVIDIA CUDA toolkit, NVIDIA GPU driver, docker, and nvidia-container-toolkit
[2] Install NVIDIA CUDA Toolkit and NVIDIA GPU driver
[3] Install NVIDIA GPU driver
[4] Uninstall NVIDIA CUDA toolkit and NVIDIA GPU driver
[E] Exit
Your choice: " -a array
for choice in "${array[@]}"; do
case $choice in
[1])
echo -e "${YELLOW}Verifying CUDA tookit repository. Please wait...${ENDCOLOR}"
sleep 1
if [[ $IS_CUDA_KEYRING -ne 0 && $UBUNTU_VER = "20.04" ]]; then
    wget --no-check-certificate -P /opt/ https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i /opt/cuda-keyring_1.1-1_all.deb
    rm -rf /opt/cuda-keyring_1.1-1_all.deb
elif [[ $IS_CUDA_KEYRING -ne 0 && $UBUNTU_VER = "22.04" ]]; then
    wget --no-check-certificate -P /opt/ https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i /opt/cuda-keyring_1.1-1_all.deb
    rm -rf /opt/cuda-keyring_1.1-1_all.deb
elif [[ $IS_CUDA_KEYRING -ne 0 && $UBUNTU_VER = "24.04" ]]; then
    wget -q -P /opt/ https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i /opt/cuda-keyring_1.1-1_all.deb
    rm -rf /opt/cuda-keyring_1.1-1_all.deb
fi

echo -e "${YELLOW}Verifying nvidia-container-toolkit repository. Please wait...${ENDCOLOR}"
sleep 1
if [ ! -s /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg ] || [ ! -s /etc/apt/sources.list.d/nvidia-container-toolkit.list ]; then
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
fi

echo -e "${YELLOW}Verifying Docker repository. Please wait...${ENDCOLOR}"
sleep 1
if [ ! -s /etc/apt/keyrings/docker.gpg ] || [ ! -s /etc/apt/sources.list.d/docker.list ]; then
    mkdir -p /etc/apt/keyrings && chmod 0755 /etc/apt/keyrings
    curl -kfsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

echo -e "${YELLOW}Installing CUDA toolkit, NVIDIA driver, docker, and nvidia-container-toolkit. Please wait...${ENDCOLOR}"
apt update
apt install cuda-toolkit "$(nvidia-detector)" "$(nvidia-detector | sed 's/driver/dkms/g')" nvidia-prime docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin nvidia-container-toolkit -y
nvidia-ctk runtime configure --runtime=docker
systemctl enable docker
echo -e "${GREEN}Done! Please reboot your computer.${ENDCOLOR}"
sleep 1
exit 0
;;
[2])
echo -e "${YELLOW}Verifying CUDA tookit repo, please wait...${ENDCOLOR}"
sleep 1
if [[ $IS_CUDA_KEYRING -ne 0 && $UBUNTU_VER = "20.04" ]]; then
    wget --no-check-certificate -P /opt/ https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i /opt/cuda-keyring_1.1-1_all.deb
    rm -rf /opt/cuda-keyring_1.1-1_all.deb
elif [[ $IS_CUDA_KEYRING -ne 0 && $UBUNTU_VER = "22.04" ]]; then
    wget --no-check-certificate -P /opt/ https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i /opt/cuda-keyring_1.1-1_all.deb
    rm -rf /opt/cuda-keyring_1.1-1_all.deb
elif [[ $IS_CUDA_KEYRING -ne 0 && $UBUNTU_VER = "24.04" ]]; then
    wget -q -P /opt/ https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i /opt/cuda-keyring_1.1-1_all.deb
    rm -rf /opt/cuda-keyring_1.1-1_all.deb
fi
echo -e "${YELLOW}Installing CUDA toolkit and NVIDIA driver. Please wait...${ENDCOLOR}"
sleep 1
apt update
apt install cuda-toolkit "$(nvidia-detector)" "$(nvidia-detector | sed 's/driver/dkms/g')" nvidia-prime -y
if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
    prime-select on-demand
fi
echo -e "${GREEN}Done! Please reboot your computer.${ENDCOLOR}"
sleep 1
exit 0
;;
[3])
echo -e "${YELLOW}Installing latest NVIDIA driver. Please wait...${ENDCOLOR}"
sleep 1
apt update
apt -y install "$(nvidia-detector)" "$(nvidia-detector | sed 's/driver/dkms/g')" nvidia-prime
if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
    prime-select on-demand
fi
echo -e "${GREEN}Done! Please reboot your computer.${ENDCOLOR}"
sleep 1
exit 0
;;
[4])
echo -e "${YELLOW}Removing NVIDIA CUDA toolkit and NVIDIA driver. Please wait...${ENDCOLOR}"
sleep 1
apt remove cuda-toolkit ^nvidia-* ^libnvidia-* -y
apt autoremove --purge
apt install nvidia-container-toolkit -y
nvidia-ctk runtime configure --runtime=docker
echo -e "${GREEN}Done! Please reboot your computer.${ENDCOLOR}"
sleep 1
exit 0
;;
[Ee]) echo -e "${YELLOW}Exiting...${ENDCOLOR}"
exit 0
;;
*)
echo -e "${RED}Invalid entry. Please retry or [E]Exit${ENDCOLOR}"
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

if dpkg --compare-versions "$UBUNTU_VER" ge "20.04" && [ $IS_NVGPU -eq 0 ]; then
service systemd-resolved restart
nv_cuda
elif dpkg --compare-versions "$UBUNTU_VER" lt "20.04"; then
echo -e "${RED}This OS version is no longer supported, please upgrade it to at least Ubuntu 20.04.${ENDCOLOR}"
echo -e "${RED}Exiting...${ENDCOLOR}"
exit 1
elif
[[ $IS_NVGPU != 0 ]]; then
echo -e "${YELLOW}This computer does not have an NVIDIA GPU. NVIDIA GPU driver is not required.${ENDCOLOR}"
echo -e "${YELLOW}Exiting...${ENDCOLOR}"
exit 1
fi
