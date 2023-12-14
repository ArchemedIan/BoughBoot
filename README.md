# BoughBoot
###  POC/WIP touchscreen multiboot for orangepi 5 plus 
Note: (5/5b support not tested but planned )


## Basic usage
- download latest image from releases
- install it to an sdcard, and wipe your SPI
- boot to boughboot, connect to the internet and manually install an image (see below, an os installer is planned)
- return to the bootmenu (type `bb` in a terminal)
- pick the option to add a menu item
- follow prompts, name you entry, set the partitions, etc.
- use entry to test

### notes:
- you will always reboot to boughboot after a boot to another os is attemoted, whether it succedes or fails to boot. there is no `sticky` boot at the moment, but it is planned for a future release.
- `/NextBootEnv.txt` is the file that instructs uboot to boot to a different OS. 
- there is a symlink at `/boot/BB/NextBootEnv.txt`, that is for the use of the bootmenu, not uboot, and should be left alone.
- I'VE ONLY TESTED A FEW REGULAR LINUX DISTROS. openfyde/android/batocera/openwrt or any other specialized os is not yet supported, but will be attempted/tested in the future
- only SD and eMMC have been tested, but NVMe should work, sata and usb might not, needs testing
- use at your own risk, but this should not damage you device in anyway. clearing your spi and removing the sdcard returns the bootflow back to normal (whatever you decide to install)


## unfinished, basic os install guide
- so basically, download an image for your device, extract it, and mount it to a loop device. (`losetup -f /path/to/device.img` use `losetup` on its own to find out which device it is mounted to)
- inspect it with gparted or something similar, find out how many partitions it has, and mount them somewhere
- create the necessary amount of partitions on your storage device, and mount both partitons somewhere
- copy files from the source image partition, to the corresponding partition on your storage, using the command below:
- `rsync -aHSAX -ih /mounted/source/partition/ /mounted/destination/partition`
- TAKE NOTE that in the above command, the source path has a slash (`/`) at the end, and the destination path DOES NOT. if you type it wrong, you will end up with a folder on the root of the partiton.
- unmount all partitions, unmount the image from a loopdev.



## Plans:
- SPI, bootmenu-less version, sticky support. ( useful for kodi/emulationstation dualboot situations )
- basic OS installer
- (distant future) better gui maybe? hotspot for headless dualbooting? 
- attempt to make boot faster using alpine/buildroot or similar
