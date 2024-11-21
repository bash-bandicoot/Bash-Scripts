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
[4] Uninstall NVIDIA GPU driver and NVIDIA CUDA toolkit
[E] Exit
Your choice: " -a array
for choice in "${array[@]}"; do
case $choice in
[1])
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
[ ! -s /etc/yum.repos.d/nvidia-container-toolkit.repo ] && curl -s -k -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | tee /etc/yum.repos.d/nvidia-container-toolkit.repo
dnf -y copr enable sunwire/envycontrol
if [[ $SB_STATE -ne 0 ]]; then
        dnf -y module install nvidia-driver:open-dkms
        dnf -y install cuda-toolkit-12-6 gcc13 docker-ce nvidia-container-toolkit python3-envycontrol
        nvidia-ctk runtime configure --runtime=docker
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                envycontrol -s hybrid --rtd3 >/dev/null
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
echo -e "${GREEN}Done! Please reboot the computer and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
elif [[ $SB_STATE -eq 0 ]]; then
        echo -e "${YELLOW}Please create one-time MOK password (123456789)${ENDCOLOR}"
        sleep 1
        mokutil --import /etc/pki/akmods/certs/public_key.der
        dnf -y module install nvidia-driver:open-dkms
        dnf -y install cuda-toolkit-12-6 gcc13 docker-ce nvidia-container-toolkit python3-envycontrol
        nvidia-ctk runtime configure --runtime=docker
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                envycontrol -s hybrid --rtd3 >/dev/null
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
echo -e "${GREEN}Done! Please reboot the computer and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
fi
;;
[2])
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo
dnf -y copr enable sunwire/envycontrol
if [[ $SB_STATE -ne 0 ]]; then
        dnf -y module install nvidia-driver:open-dkms
        dnf -y install cuda-toolkit-12-6 gcc13 python3-envycontrol
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                envycontrol -s hybrid --rtd3 >/dev/null
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
echo -e "${GREEN}Done! Please reboot the computer and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
elif [[ $SB_STATE -eq 0 ]]; then
        echo -e "${YELLOW}Please create one-time MOK password (123456789)${ENDCOLOR}"
        sleep 1
        mokutil --import /etc/pki/akmods/certs/public_key.der
        dnf -y module install nvidia-driver:open-dkms
        dnf -y install cuda-toolkit-12-6 gcc13 python3-envycontrol
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                envycontrol -s hybrid --rtd3 >/dev/null
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
echo -e "${GREEN}Done! Please reboot the computer and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
fi
;;
[3])
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo
dnf -y copr enable sunwire/envycontrol
if [[ $SB_STATE -ne 0 ]]; then
        dnf -y module install nvidia-driver:open-dkms
        dnf -y install python3-envycontrol
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                envycontrol -s hybrid --rtd3 >/dev/null
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
echo -e "${GREEN}Done! Please reboot the computer and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
elif [[ $SB_STATE -eq 0 ]]; then
        echo -e "${YELLOW}Please create one-time MOK password (123456789)${ENDCOLOR}"
        sleep 1
        mokutil --import /etc/pki/akmods/certs/public_key.der
        dnf -y module install nvidia-driver:open-dkms
        dnf -y install python3-envycontrol
        if [[ $CHECK_LAPTOP -eq 0 || $CHECK_LAPTOP2 -eq 0 || $CHECK_LAPTOP3 -eq 0 ]]; then
                envycontrol -s hybrid --rtd3 >/dev/null
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
echo -e "${GREEN}Done! Please reboot the computer, enroll MOK, and test NVIDIA driver${ENDCOLOR}"
sleep 1
exit 0
fi
;;
[4])
echo -e "${YELLOW}Removing NVIDIA CUDA toolkit and NVIDIA driver. Please wait...${ENDCOLOR}"
sleep 1
dnf -y module remove nvidia-driver:open-dkms
dnf -y remove cuda-toolkit-12-6
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
