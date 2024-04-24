# QEMU-PCIE-GPU-Passthrough
![image](https://github.com/ahaas25/QEMU-PCIE-GPU-Passthrough/assets/94150901/ade6d743-e51f-43ce-a23b-c6a710b048d0)
![image](https://github.com/ahaas25/QEMU-PCIE-GPU-Passthrough/assets/94150901/69f0a2f6-576d-4934-82d1-e38f63411309)
My QEMU configuration files for passing my RTX 3070 to a Windows 11 VM.

# Credits
This is a simplified guide based on [here](https://github.com/martinopiaggi/Single-GPU-Passthrough-for-Dummies). I highly recommend reading this guide to get a better understanding of how this works.

# Patched VBIOS (NVIDIA Only)
I've provided my patched VBIOS as an example of what a correctly patched image should look like. Find the VBIOS for your graphics card and download it. Use a Hex editor to modify the rom file and search for the first instance of `VIDEO`. Look to the left of it for a `U`. Delete everything before the `U`.

# Setup Overview
This is my simplified guide based off a lot of troubleshooting.
1. Enable IOMMU and Virtualization in your BIOS.
2. Install `qemu`, `libvirt`, `virt-manager` and necessary libraries.
3. Create a Windows VM using `virt-manager` using default settings. (No device passthrough yet)
4. Ensure CPU topology is correct under `CPUs` tab. (Mine was set incorrectly by default)
5. Install Windows and ensure VM works.
6. Find your GPU's PCI bus using `lspci`. In my case my GPU is on `pci_0000_08_00_0` and the audio controller is `pci_0000_08_00_1`
7. Modify `start.sh` and `stop.sh` to suite your configuration. Change any lines refering to the GPU bus to your systems (Mine is `pci_0000_08_00_0`). Make sure to change `gdm` to your display manager if you are not using GNOME.
8. Copy `start.sh` and `stop.sh` scripts in `/etc/libvirt/hooks/qemu.d/<your_vm_name>/` keeping the file structure the same as in this repository. Ensure the scripts are executable with `chmod +x <script>`
9. Add your GPU to the virtual machine using the `Add Hardware` button. Add a `PCI Host Device` for both your graphics card and graphics card audio controller.
10. Enable XML editing for `virt-manager`. Navigate to your GPU's XML config (only for the GPU, not the audio controller) and add your custom GPU ROM under the line `</source>` with `<rom file="<path/to/bios>/<bios>.rom"/>` Note: If `libvirtd` cannot access your BIOS rom, put the ROM in `/usr/share/vgabios/<bios>.rom`
12. Start the VM. If all went well, your screen should go blank and come back to your Windows VM!

# Troubleshooting
If your VM returns you back to your display manager, run `journalctl -u libvirtd` to see what the issue is. I also found it helpful to SSH into my computer and run `virt-manager` remotely so I could see the errors (I was getting a CPU topology error which was not showing up in journalctl, but did show up in the `virt-manager` GUI). You may also find it helpful to reference my VM's XML file which is also provided in this repository. 

If `modprobe` is unable to remove nvidia modules, run `nvidia-smi` to see if there are still programs running on the GPU. If there are programs still running on the GPU, you'll need to ensure they are killed in `start.sh` before starting the VM.

# My Configuration:
Linux Mint 21.3 using GNOME, Kernel 6.5.0-25-generic, NVIDIA Driver 545.29.06

Specs: AMD CPU, Gigabyte X570 motherboard, RTX 3070 GPU

VM OS: Windows 11
