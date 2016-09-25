mmc0      > **GANG**               - emmc.img - Entire flash

mbr       > **BOOT** [512B]        - boot.bin - Primary bootloader

mmc0blk1  > **EFS** [21MiB]        - efs.img - IMEI, MACs, network lock

mmc0blk2  > **SBL1** [1.2MiB]      - Sbl.img - Secondary Bootloader (uBoot?)

mmc0blk3  > **SBL2** [1.2MiB]      - null - empty

mmc0blk4  > **PARAM** [8MiB]       - param.lfs - Stock images for download mode

mmc0blk5  > **KERNEL** [8MiB]      - recovery.img - Kernel for both normal boot and recovery + Recovery

mmc0blk6  > **RECOVERY** [8MiB]    - null - Optional recovery, usually empty

mmc0blk7  > **CACHE** [100MiB]     - cache.img - Consumer Software Customization (XML files + Branding Images, boot splash, ringtones and wallpapers)

mmc0blk8  > **MODEM** [16MiB]      - modem.bin - Modem firmware

mmc0blk9  > **FACTORYFS** [512MiB] - factoryfs.img / system.img - /system

mmc0blk10 > **DATAFS** [2000MiB]   - data.img - /data partition

mmc0blk11 > **UMS** [14000MiB]     - null - /sdcard0

mmc0blk12 > **HIDDEN** [512MiB]    - hidden.img - Preloaded stock apks
