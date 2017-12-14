### Hibernate on Parabola or Arch with LUKS+LVM full disk encryption


1. Add the "resume" hook after "lvm" in /etc/mkinitcpio.conf

https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate#Configure_the_initramfs


2. Redo the ramdisk for all your kernels

    mkinitcpio -p linux-libre{-lts,-grsec}


3. Edit the Libreboot image to include the resume=</dev/mapper/lvm-partition> kernel parameter in grub

https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate#Required_kernel_parameters

https://libreboot.org/docs/gnulinux/encrypted_parabola.html


4. Set a lower swappiness value so the swap doesn't get abused by the system

    /etc/sysctl.d/99-sysctl.conf

    vm.swappiness=10
