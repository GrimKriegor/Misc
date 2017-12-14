# PCI-Passthrough Notes


## Complete tutorials and guides

[PCI passthrough via OVMF - Arch Linux Wiki][1]


## BIOS/UEFI settings

For Intel enable VT-x / VT-d

For AMD enable AMD-v / AMD-Vi


## System packages

    sudo pacman -S qemu libvirt ovmf virt-manager

    sudo systemctl enable --now libvirtd
    
    sudo systemctl enable virtlogd.socket


## Kernel parameters

IOMMU is a generic name for Intel VT-d and AMD-Vi. 

**/etc/defaults/grub**

Add to the kernel parameters

    iommu=on {intel,amd}_iommu=on pcie_acs_override=downstream

Redo the GRUB config

    grub-mkconfig -o /boot/grub/grub.cfg

Reboot and check if its on

    dmesg | grep -e IOMMU -e DMAR


## IOMMU groups

Smallest set of physical devices passable to a guest VM

IOMMU groups helper script

```bash
#!/bin/bash
shopt -s nullglob
for d in /sys/kernel/iommu_groups/*/devices/*; do 
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
done;
```

Example output

```
...
IOMMU Group 1 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GK104 [GeForce GTX 760] [10de:1187] (rev a1)
IOMMU Group 1 01:00.1 Audio device [0403]: NVIDIA Corporation GK104 HDMI Audio Controller [10de:0e0a] (rev a1)
...
```

## Isolate devices from the host

VFIO-PCI - provisional driver that holds the devices until the guest requires them

**/etc/modprobe.d/vfio.conf**

    options vfio-pci ids=10de:1187,10de:0e0a

Make sure VFIO-PCI gets loaded before the other drivers

**/etc/mkinitcpio.conf**

```
MODULES=(... vfio vfio_iommu_type1 vfio_pci vfio_virqfd)
...
HOOKS=(... modconf)
```

Redo the initramfs

    mkinitcpio -p linux


## Tell QEMU to be aware of OVMF

**/etc/libvirt/qemu.conf**

```
nvram = [
    "/usr/share/ovmf/ovmf_code_x64.bin:/usr/share/ovmf/ovmf_vars_x64.bin"
]
```


## Configuration thru VirtManager

Add new VM, set to **configure before installation**.

Set boot firmware to UEFI/OVMF.

Add GPU and GPU Audio PCI devices.

Set HDD to VirtIO (OPTIONAL), add two CD drives in SATA.

Set boot order to Windows CD, [VirtIO driver CD][2] (OPTIONAL), Windows HDD.


## Error 43 in Windows

NVIDIA's driver goofs out whenever it detects its running on a virtual machine, to force users to buy their QUATRO cards. [Hide that fact from the guest][3].

    virst edit Windows

```xml
<domain>
    ...
        <features>
            ...
            <kvm>
                <hidden state='on'/>
            </kvm>
            ...
            <hyperv>
                ...
                <vendor_id state='on' value='whatever'/>
            </hyperv>
            ...
        </features>
    ...
</domain>
```


## NFS shares [OPTIONAL]

On a GNU/Linux host

**/etc/exports**

```
/srv/nfs		192.168.122.0/24(rw,fsid=root,crossmnt,insecure)
/srv/nfs/games	192.168.122.0/24(rw,insecure)
```

Let Windows access the shares

Go to Control Panel → Programs → Programs and Features
Select: Turn Windows features on or off" from the left hand navigation.
Scroll down to "Services for NFS" and click the "plus" on the left
Check "Client for NFS"

    mount \\192.168.122.1\srv\nfs\games z:

Strange link for the weird programs

    subst G: \\192.168.122.1\srv\nfs\games


## VFIO interrupts [OPTIONAL]

[Terrible HDMI audio][4] is a common occurence

The summary of the procedure is to identify the Device Instance Path from the Details tab of the device in Device Manager.
Run regedit and find the same path under HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\  
After following down the tree using the Device Instance Path information, continue to follow down through "Device Parameters" and "Interrupt Management".
Here you will find that you either have or need to create a new key named "MessageSignaledInterruptProperties".  Within that key, find or create a DWORD value named "MSISupported".
The value should be 1 enable MSI or 0 to disable.

**msi_enable.reg**

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\PCI\VEN_10DE&DEV_0E0A&SUBSYS_847A1043&REV_A1\3&13c0b0c5&0&50\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties]
"MSISupported"=dword:00000001
```


[1]: https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF

[2]: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

[3]: https://github.com/sk1080/nvidia-kvm-patcher

[4]: https://vfio.blogspot.pt/2014/09/vfio-interrupts-and-how-to-coax-windows.html
