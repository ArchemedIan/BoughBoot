#!/bin/bash
bb_ver=$1
armbian_board=$2
armbian_imgname=$3
boards_name=$4

version=$bb_ver
rootdir=$(pwd)
NewName=BoughBoot-$version-$boards_name
cd armbian
chmod a+x userpatches/customize-image.sh
sudo --user $SUDO_USER ./compile.sh BOARD=$armbian_board BRANCH=legacy RELEASE=bookworm KERNEL_CONFIGURE=no CLEAN_LEVEL=alldebs,images,debs
cd ..
cp armbian/output/images/$armbian_imgname bb/
cd bb 
bbimg=`pwd`/`ls $armbian_imgname|cut -d' ' -f1`
echo bbimg is $bbimg
NewImg=$rootdir/out/${NewName}.img
NewTar=$rootdir/out/${NewName}.tar.xz
losetup -f $bbimg
bbimgloopdev=`losetup |grep $armbian_imgname | awk '{print $1}'`
echo $bbimgloopdev
partx -a "$bbimgloopdev" ||true
[ -d 2 ] || mkdir 2
[ -d $NewName ] || mkdir $NewName
[ -d $rootdir/out ] || mkdir $rootdir/out
mount ${bbimgloopdev}p2 2
mount ${bbimgloopdev}p1 2/boot
newimgsize=$((`sudo du -d0 2|awk '{print $1}'`+1536000))
fallocate -l ${newimgsize}K $NewImg
losetup -f $NewImg
NewImgloopdev=`losetup |grep BoughBoot_${version}.img | awk '{print $1}'`
dd if=/dev/zero of=${NewImgloopdev} count=4096 bs=512
parted --script ${NewImgloopdev} -- \
mklabel gpt \
mkpart primary ext4 16MiB -32768s \
name 1 BoughBoot
partx -a ${NewImgloopdev}||true
mkfs.ext4 -L Boughboot ${NewImgloopdev}p1
dd if=$rootdir/bb/idbloader.img of=${NewImgloopdev} seek=64 conv=notrunc status=none
dd if=$rootdir/bb/u-boot.itb of=${NewImgloopdev} seek=16384 conv=notrunc status=none
tune2fs -O ^metadata_csum ${NewImgloopdev}p1
NewImgDir=$rootdir/$NewName
[ -d $NewImgDir ] || mkdir $NewImgDir
mount ${NewImgloopdev}p1 $NewImgDir
rsync -aHSAX -ih --progress 2/ $NewImgDir
sync
mkdir $NewImgDir/boot/u-boot-Boughboot
mkdir $rootdir/out/u-boot-Boughboot/
cp $rootdir/bb/u-boot* $NewImgDir/boot/u-boot-Boughboot/
cp $rootdir/bb/idbloader.img $NewImgDir/boot/u-boot-Boughboot/
cp $rootdir/bb/idbloader-spi.img $NewImgDir/boot/u-boot-Boughboot/
cp $rootdir/bb/u-boot* $rootdir/out/u-boot-Boughboot/
cp $rootdir/bb/idbloader.img $rootdir/out/u-boot-Boughboot/
cp $rootdir/bb/idbloader-spi.img $rootdir/out/u-boot-Boughboot/
bakdir=$(pwd)
cd $NewImgDir
[ -e $NewTar ] && rm $NewTar
tar caf - . | xz -czT0 -0 > $NewTar
sync
rootuuid=`blkid -s UUID -o value ${NewImgloopdev}p1`
sed "s|UUID=.* / |UUID=$rootuuid / |g" -i etc/fstab
sync
sed  "s|UUID=.* /boot|#UUID= /boot|g" -i etc/fstab
touch BoughBootEnv.txt
echo BBDevType=unset > BoughBootEnv.txt
echo BBDevNum=unset >> BoughBootEnv.txt
echo BBRootNum=unset >> BoughBootEnv.txt
echo BBEnvNum=unset >> BoughBootEnv.txt
echo BBfdtfile=rockchip/rk3588-orangepi-5-plus.dtb >> BoughBootEnv.txt
echo BBEnvFileSize=unset >> BoughBootEnv.txt
touch NextBootEnv.txt
echo BBMenuName=unset > NextBootEnv.txt
echo BBMenuDescription=unset >> NextBootEnv.txt
echo NBDevType=unset >> NextBootEnv.txt
echo NBDevNum=unset >> NextBootEnv.txt
echo NBBootNum=unset >> NextBootEnv.txt
echo NBRootNum=unset >> NextBootEnv.txt
echo NBPrefix=unset >> NextBootEnv.txt
echo NBOSType=unset >> NextBootEnv.txt
echo NBnow=0 >> NextBootEnv.txt
mkdir /opt/BB
cp -r $rootdir/build-bb/dev/* opt/BB

cd $bakdir
umount $NewImgDir

partx -d ${NewImgloopdev}p1
losetup -d ${NewImgloopdev}
umount 2/boot 2
partx -d "$bbimgloopdev"
losetup -d "$bbimgloopdev"
sync
sleep 2
