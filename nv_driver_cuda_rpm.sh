#!/bin/bash

## NVIDIA GPU driver/CUDA install script for Fedora/RHEL ##

YELLOW="\033[1;33m"
RED="\033[0;31m"
GREEN="\033[0;32m"
ENDCOLOR="\033[0m"

SB_STATE=$(mokutil --sb-state >/dev/null); SB_STATE=$?
IS_NVGPU=$(lspci | grep NVIDIA >/dev/null); IS_NVGPU=$?

if [ $USER != root ]; then
          echo -e $RED"Error: must be run with sudo"
            echo -e $YELLOW"Exiting..."$ENDCOLOR
              exit 1
      fi


dnf config-manager --set-enabled rpmfusion-nonfree-nvidia-driver
dnf -y copr enable sunwire/envycontrol
if [[ $IS_NVGPU -eq 0 && $SB_STATE -ne 0 ]]; then
dnf -y install akmod-nvidia akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda python3-envycontrol
akmods --force
dracut --force
envycontrol -s hybrid --rtd3 >/dev/null
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
echo -e $GREEN"Done! Please reboot the computer and test NVIDIA driver"$ENDCOLOR
elif [[ $IS_NVGPU -eq 0 && $SB_STATE -eq 0 ]]; then
echo -e $YELLOW"Please create one-time MOK password (123456789)"$ENDCOLOR
sleep 1
mokutil --import /etc/pki/akmods/certs/public_key.der
dnf -y install akmod-nvidia akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda python3-envycontrol
akmods --force
dracut --force
envycontrol -s hybrid --rtd3 >/dev/null
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
mokutil --timeout 1000
echo -e $GREEN"Done! Please reboot the computer, enroll MOK, and test NVIDIA driver"$ENDCOLOR
else
echo -e $YELLOW"No NVIDIA GPU detected. Exiting..."$ENDCOLOR
exit 1
fi