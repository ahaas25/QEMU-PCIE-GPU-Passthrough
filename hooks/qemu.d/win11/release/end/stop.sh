#!/bin/bash
set -x

## Load the config file
#source "/etc/libvirt/hooks/kvm.conf"

# Unload VFIO-PCI Kernel Driver
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Re-Bind GPU to AMD Driver
#virsh nodedev-reattach $VIRSH_GPU_VIDEO
#virsh nodedev-reattach $VIRSH_GPU_AUDIO
virsh nodedev-reattach pci_0000_08_00_0
virsh nodedev-reattach pci_0000_08_00_1


# Rebind VT consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

#nvidia-xconfig --query-gpu-info > /dev/null 2>&1
# Re-Bind EFI-Framebuffer
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

#Load nvidia driver
modprobe nvidia_drm
modprobe nvidia_uvm
modprobe nvidia_modeset
modprobe drm_kms_helper
modprobe nvidia
modprobe i2c_nvidia_gpu
modprobe drm

# Restart Display Manager
systemctl start gdm3
