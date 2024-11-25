#!/bin/bash

## NVIDIA GPU driver/CUDA install script for Fedora/RHEL ##

YELLOW="\033[1;33m"
RED="\033[0;31m"
GREEN="\033[0;32m"
ENDCOLOR="\033[0m"


if [[ $USER != root ]]; then
        echo -e "${RED}Error: must be run with sudo${ENDCOLOR}"
        echo -e "${YELLOW}Exiting...${ENDCOLOR}"
        exit 1
fi

SB_STATE=$(mokutil --sb-state >/dev/null); SB_STATE=$?
IS_NVGPU=$(lspci | grep NVIDIA >/dev/null); IS_NVGPU=$?
CHECK_LAPTOP=$(ls /proc/acpi/button/lid 2>&1 >/dev/null); CHECK_LAPTOP=$?
CHECK_LAPTOP2=$(dmidecode -t chassis | grep Notebook >/dev/null); CHECK_LAPTOP2=$?
CHECK_LAPTOP3=$(dmidecode -t chassis | grep Convertible >/dev/null); CHECK_LAPTOP3=$?

function nv_cuda_rpm ()
{
while true; do
read -rp "[1] Install NVIDIA GPU driver, NVIDIA CUDA toolkit, docker, and nvidia-container-toolkit
[2] Install NVIDIA GPU driver and NVIDIA CUDA Toolkit
[3] Install NVIDIA GPU driver
[4] Uninstall NVIDIA GPU driver
[E] Exit
Your choice: " -a array
for choice in "${array[@]}"; do
case $choice in
[1])
dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm
dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
[ ! -s /etc/yum.repos.d/nvidia-container-toolkit.repo ] && curl -s -k -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | tee /etc/yum.repos.d/nvidia-container-toolkit.repo
dnf -y upgrade --refresh
dnf -y module disable nvidia-driver
if [[ $SB_STATE -ne 0 ]]; then
        dnf -y install kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda kmodtool akmods mokutil openssl
        dnf -y install cuda-toolkit gcc13 docker-ce nvidia-container-toolkit
        nvidia-ctk runtime configure --runtime=docker
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                sytemctl disable nvidia-persistenced
        fi
cat > /etc/X11/xorg.conf.d/nvidia.conf << 'EOL'
Section "OutputClass"
        Identifier "nvidia"
        MatchDriver "nvidia-drm"
        Driver "nvidia"
        Option "AllowEmptyInitialConfiguration"
        Option "SLI" "Auto"
        Option "BaseMosaic" "on"
        Option "PrimaryGPU" "yes"
EndSection

Section "ServerLayout"
        Identifier "layout"
        Option "AllowNVIDIAGPUScreens"
EndSection
EOL
akmods --force
dracut --force
echo -e "${GREEN}Done! Please reboot the computer and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
elif [[ $SB_STATE -eq 0 ]]; then
        sleep 1
        echo -e "${YELLOW}Please create one-time MOK password (123456789)${ENDCOLOR}"
        mokutil --import /etc/pki/akmods/certs/public_key.der
        dnf -y install kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda kmodtool akmods mokutil openssl
        dnf -y install cuda-toolkit gcc13 docker-ce nvidia-container-toolkit
        nvidia-ctk runtime configure --runtime=docker
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                sytemctl disable nvidia-persistenced
        fi
cat > /etc/X11/xorg.conf.d/nvidia.conf << 'EOL'
Section "OutputClass"
        Identifier "nvidia"
        MatchDriver "nvidia-drm"
        Driver "nvidia"
        Option "AllowEmptyInitialConfiguration"
        Option "SLI" "Auto"
        Option "BaseMosaic" "on"
        Option "PrimaryGPU" "yes"
EndSection

Section "ServerLayout"
        Identifier "layout"
        Option "AllowNVIDIAGPUScreens"
EndSection
EOL
akmods --force
dracut --force
echo -e "${GREEN}Done! Please reboot the computer and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
fi
;;
[2])
dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm
dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo
dnf -y upgrade --refresh
dnf -y module disable nvidia-driver
if [[ $SB_STATE -ne 0 ]]; then
        dnf -y install kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda kmodtool akmods mokutil openssl
        dnf -y install cuda-toolkit gcc13
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                sytemctl disable nvidia-persistenced
        fi
cat > /etc/X11/xorg.conf.d/nvidia.conf << 'EOL'
Section "OutputClass"
        Identifier "nvidia"
        MatchDriver "nvidia-drm"
        Driver "nvidia"
        Option "AllowEmptyInitialConfiguration"
        Option "SLI" "Auto"
        Option "BaseMosaic" "on"
        Option "PrimaryGPU" "yes"
EndSection

Section "ServerLayout"
        Identifier "layout"
        Option "AllowNVIDIAGPUScreens"
EndSection
EOL
akmods --force
dracut --force
echo -e "${GREEN}Done! Please reboot the computer and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
elif [[ $SB_STATE -eq 0 ]]; then
        sleep 1
        echo -e "${YELLOW}Please create one-time MOK password (123456789)${ENDCOLOR}"
        mokutil --import /etc/pki/akmods/certs/public_key.der
        dnf -y install kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda kmodtool akmods mokutil openssl
        dnf -y install cuda-toolkit gcc13
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                sytemctl disable nvidia-persistenced
        fi
cat > /etc/X11/xorg.conf.d/nvidia.conf << 'EOL'
Section "OutputClass"
        Identifier "nvidia"
        MatchDriver "nvidia-drm"
        Driver "nvidia"
        Option "AllowEmptyInitialConfiguration"
        Option "SLI" "Auto"
        Option "BaseMosaic" "on"
        Option "PrimaryGPU" "yes"
EndSection

Section "ServerLayout"
        Identifier "layout"
        Option "AllowNVIDIAGPUScreens"
EndSection
EOL
akmods --force
dracut --force
echo -e "${GREEN}Done! Please reboot the computer and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
fi
;;
[3])
dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm
dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
dnf -y upgrade --refresh
dnf -y module disable nvidia-driver
if [[ $SB_STATE -ne 0 ]]; then
        dnf -y install kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda kmodtool akmods mokutil openssl
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                sytemctl disable nvidia-persistenced
        fi
cat > /etc/X11/xorg.conf.d/nvidia.conf << 'EOL'
Section "OutputClass"
        Identifier "nvidia"
        MatchDriver "nvidia-drm"
        Driver "nvidia"
        Option "AllowEmptyInitialConfiguration"
        Option "SLI" "Auto"
        Option "BaseMosaic" "on"
        Option "PrimaryGPU" "yes"
EndSection

Section "ServerLayout"
        Identifier "layout"
        Option "AllowNVIDIAGPUScreens"
EndSection
EOL
akmods --force
dracut --force
echo -e "${GREEN}Done! Please reboot the computer and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
elif [[ $SB_STATE -eq 0 ]]; then
        sleep 1
        echo -e "${YELLOW}Please create one-time MOK password (123456789)${ENDCOLOR}"
        mokutil --import /etc/pki/akmods/certs/public_key.der
        dnf -y install kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda kmodtool akmods mokutil openssl
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                sytemctl disable nvidia-persistenced
        fi
cat > /etc/X11/xorg.conf.d/nvidia.conf << 'EOL'
Section "OutputClass"
        Identifier "nvidia"
        MatchDriver "nvidia-drm"
        Driver "nvidia"
        Option "AllowEmptyInitialConfiguration"
        Option "SLI" "Auto"
        Option "BaseMosaic" "on"
        Option "PrimaryGPU" "yes"
EndSection

Section "ServerLayout"
        Identifier "layout"
        Option "AllowNVIDIAGPUScreens"
EndSection
EOL
akmods --force
dracut --force
echo -e "${GREEN}Done! Please reboot the computer, enroll MOK, and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
fi
;;
[4])
echo -e "${YELLOW}Removing NVIDIA driver. Please wait...${ENDCOLOR}"
sleep 1
dnf -y remove kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda
akmods --force
dracut --force
echo -e "${GREEN}Done! Please reboot your computer for changes to take effect.${ENDCOLOR}"
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

if [[ $SB_STATE -eq 0 ]]; then
mokutil --timeout 1000
fi

if [[ $IS_NVGPU -eq 0 ]]; then
systemctl restart systemd-resolved
nv_cuda_rpm
else
echo -e "${YELLOW}This computer does not have an NVIDIA GPU. NVIDIA GPU CUDA/driver is not required.${ENDCOLOR}"
echo -e "${YELLOW}Exiting...${ENDCOLOR}"
exit 1
fi
