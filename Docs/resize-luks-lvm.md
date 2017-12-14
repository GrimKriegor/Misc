# Resize LUKS and LVM things

Keep 1GiB buffers between the inner and outer layers when resizing

## Open LUKS container

    cryptsetup luksOpen /dev/sda1 lvm

## Resize filesystem

    resize2fs -p /dev/mapper/vgroup-lvhome 70g

    e2fsck -f /dev/mapper/vgroup-lvhome

## Resize logical volume

    lvreduce -L -10G /dev/vgroup/lvhome

## Resize physical volume

    pvresize --setphysicalvolumesize 102G /dev/mapper/cryptdisk

## Resize LUKS volume

    cryptsetup status cryptdisk

To calculate how many sectors we want to shrink to, use a simple formula: NEW_SECTORS = EXISTING_SECTORS * NEW_SIZE_IN_GB / EXISTING_SIZE_IN_GB. Remember to take a safety buffer here as well.

    cryptsetup -b $NEW_SECTOR_COUNT resize cryptdisk

    parted /dev/sda

## Fill logical volume with filesystem

    e2fsck -f /dev/vgroup/lvhome

    resize2fs /dev/vgroup/lvhome
