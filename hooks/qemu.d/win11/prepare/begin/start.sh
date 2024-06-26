#!/bin/bash
# Helpful to read output when debugging
set -x

## Load the config file with our environmental variables
#source "/etc/libvirt/hooks/kvm.conf"

# Stop display manager
systemctl stop gdm3
# Stop ollama
# systemctl stop ollama

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Unbind EFI-Framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid a race condition
sleep 2

# Unload all Nvidia drivers
modprobe -r nvidia_drm
modprobe -r nvidia_uvm
modprobe -r nvidia_modeset
modprobe -r drm_kms_helper
modprobe -r nvidia
modprobe -r i2c_nvidia_gpu
modprobe -r drm

# Unbind the GPU from display driver
#virsh nodedev-detach $VIRSH_GPU_VIDEO
#virsh nodedev-detach $VIRSH_GPU_AUDIO
virsh nodedev-detach pci_0000_08_00_0
virsh nodedev-detach pci_0000_08_00_1

# Load VFIO kernel module
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1
