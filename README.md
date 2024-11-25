# NVIDIA on Linux (Ubuntu/Fedora)

## Usage

    sudo bash nv_driver_cuda_deb.sh
    or
    sudo bash nv_driver_cuda_rpm.sh

    [1] Install NVIDIA GPU driver, NVIDIA CUDA toolkit, docker, and nvidia-container-toolkit
    [2] Install NVIDIA GPU driver and NVIDIA CUDA toolkit
    [3] Install NVIDIA GPU driver
    [4] Uninstall NVIDIA GPU driver
    [E] Exit
    Your choice:

### MOK enrollment how-to

- <https://cuda-installer.gitlab-master-pages.nvidia.com/kitmaker-docs/driver/gnome-software-secure-boot.html#:~:text=system%20will%20restart.-,Machine%20Owner%20Key%20enrollment,-%23>

### CUDA Environment Variables

- To add CUDA path to user's environment variables, please do (BASH example):
- Open Terminal
- echo 'export PATH=${PATH}:/usr/local/cuda/bin/' >> $HOME/.bashrc
- source $HOME/.bashrc

### To-Do

- On Fedora 40/41 we're using Fedora 39 CUDA repo (12.6) since NVIDIA is still working on Fedora 41 CUDA repo (12.8)
