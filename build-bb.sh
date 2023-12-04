#!/bin/bash
set -xe
bb_ver=$1
armbian_board=$2
armbian_imgname=$3
boards_name=$4

if [[ "$bb_ver" == *"-dev"* ]]; then
  version=$bb_ver
else
  if [ ! -d "$rootdir/build-bb/$bb_ver" ]; then
    bb_ver=${bb_ver}-dev
    version=$bb_ver
  fi
fi

rootdir=$(pwd)
NewName=BoughBoot-$version-$boards_name
echo bb_ver=$bb_ver
echo version=$version
echo armbian_board=$armbian_board
echo armbian_imgname=$armbian_imgname
echo boards_name=$boards_name
sleep 60
cp -r ./build-bb/userpatches ./armbian/
chmod a+x ./armbian/userpatches/customize-image.sh
ls -l
cd armbian
ls -l
sudo --user $SUDO_USER ./compile.sh BOARD="${armbian_board}" BUILD_DESKTOP="no" VENDOR="BoughBoot" BRANCH="legacy" BUILD_MINIMAL="no" KERNEL_CONFIGURE="no" RELEASE="bookworm" BOOTFS_TYPE="ext4" WIREGUARD="no"
cd ..
cp armbian/output/images/$armbian_imgname bb/
cd bb 
bbimg=`pwd`/`ls $armbian_imgname|cut -d' ' -f1`
echo bbimg is $bbimg
cp $bbimg $rootdir/out
NewImg=$rootdir/out/${NewName}.img
NewTar=$rootdir/out/${NewName}-rootfs.tar.xz
losetup -f $bbimg
bbimgloopdev=`losetup |grep $armbian_imgname | awk '{print $1}'`
echo bbimgloopdev is $bbimgloopdev
partprobe $bbimgloopdev
[ -d 2 ] || mkdir 2
[ -d $NewName ] || mkdir $NewName
[ -d $rootdir/out ] || mkdir $rootdir/out
mount ${bbimgloopdev}p2 2
mount ${bbimgloopdev}p1 2/boot

newimgsize=$((`sudo du -d0 2|awk '{print $1}'`+1536000))
echo newimgsize is $newimgsize
fallocate -l ${newimgsize}K $NewImg
losetup -f $NewImg
NewImgloopdev=`losetup |grep BoughBoot-$version-$boards_name | awk '{print $1}'`
echo NewImgloopdev is $NewImgloopdev
dd if=/dev/zero of=${NewImgloopdev} count=4096 bs=512
parted --script ${NewImgloopdev} -- \
mklabel gpt \
mkpart primary ext4 16MiB -32768s \
name 1 BoughBoot
partprobe $NewImgloopdev
mkfs.ext4 -L Boughboot ${NewImgloopdev}p1
partprobe $NewImgloopdev
dd if=$rootdir/bb/idbloader.img of=${NewImgloopdev} seek=64 conv=notrunc status=none
dd if=$rootdir/bb/u-boot.itb of=${NewImgloopdev} seek=16384 conv=notrunc status=none
tune2fs -O ^metadata_csum ${NewImgloopdev}p1
partprobe $NewImgloopdev
partprobe
NewImgDir=$rootdir/$NewName
[ -d $NewImgDir ] || mkdir $NewImgDir
mount ${NewImgloopdev}p1 $NewImgDir
rsync -aHSAX -ih 2/ $NewImgDir >/dev/null
sync
mkdir $NewImgDir/boot/u-boot-Boughboot
mkdir $rootdir/out/u-boot-Boughboot/
cp $rootdir/bb/u-boot* $NewImgDir/boot/u-boot-Boughboot/
cp $rootdir/bb/idbloader.img $NewImgDir/boot/u-boot-Boughboot/
cp $rootdir/bb/idbloader-spi.img $NewImgDir/boot/u-boot-Boughboot/
#cp $rootdir/bb/u-boot* $rootdir/out/u-boot-Boughboot/
#cp $rootdir/bb/idbloader.img $rootdir/out/u-boot-Boughboot/
#cp $rootdir/bb/idbloader-spi.img $rootdir/out/u-boot-Boughboot/
bakdir=$(pwd)
cd $NewImgDir
rootuuid=`blkid -s UUID -o value ${NewImgloopdev}p1`
echo rootuuid is $rootuuid
sed "s|UUID=.* / |UUID=$rootuuid / |g" -i etc/fstab
sync
sed  "s|UUID=.* /boot|#UUID= /boot|g" -i etc/fstab
rsync -aHSAX -ih etc/skel/ root >/dev/null
echo chmod a+x /boot/BB/BBMenu-cli.sh > root/.bashrc
echo alias BBMenu-cli=/boot/BB/BBMenu-cli.sh >> root/.bashrc
echo alias BBMenu-cli.sh=/boot/BB/BBMenu-cli.sh >> root/.bashrc
echo alias BBMenu=/boot/BB/BBMenu-cli.sh >> root/.bashrc
echo alias bbmenu=/boot/BB/BBMenu-cli.sh >> root/.bashrc
echo alias bb=/boot/BB/BBMenu-cli.sh >> root/.bashrc
echo "alias wifi=\"echo y\| armbian-config main=Network selection=WiFi\"">> root/.bashrc
echo "alias network=\"echo y\| armbian-config main=Network selection=WiFi\"">> root/.bashrc
echo /boot/BB/BBMenu-cli.sh >> root/.bashrc >> root/.bashrc
sed "s|orangepi5-plus|BoughBoot|g" -i etc/hostname
sed "s|orangepi5-plus|BoughBoot|g" -i etc/hosts
mkdir boot/BB

if [[ "$bb_ver" == *"-dev"* ]]; then
  rsync -aHSAX -ih $rootdir/build-bb/dev/ boot/BB
else
  rsync -aHSAX -ih $rootdir/build-bb/$bb_ver/ boot/BB
fi

ln -sr boot/BB/*.txt . 
sync
tar caf - . | xz -czT0 -6 > $NewTar
sync
cd $bakdir
umount $NewImgDir
partprobe $bbimgloopdev
partprobe ${NewImgloopdev}
partprobe
losetup -d ${NewImgloopdev}
umount 2/boot 2
partx -d "$bbimgloopdev"
losetup -d "$bbimgloopdev"
sync
sleep 2
cd $rootdir/out
ls
xz -zkT0 -6 ${NewImg}
ls
sync
