#!/bin/bash

BR_OUTPUT_DIR=${1}
HOST_DIR="${BR_OUTPUT_DIR}/host"
UBOOT_DIR="${BR_OUTPUT_DIR}/images"
OUTPUT_DIR="${UBOOT_DIR}"

FEL=sunxi-fel
NAND_IMAGE_BUILDER=sunxi-nand-image-builder

filesize() {
    stat --printf="%s" $1
}

# build the SPL image
prepare_spl() {
  local tmpdir=`mktemp -d -t chip-spl-XXXXXX`
  local outputdir=$1
  local spl=$2
  local eraseblocksize=$3
  local pagesize=$4
  local oobsize=$5
  local repeat=$((eraseblocksize/pagesize/64))
  local nandspl=$tmpdir/nand-spl.bin
  local nandpaddedspl=$tmpdir/nand-padded-spl.bin
  local ebsize=`printf %x $eraseblocksize`
  local psize=`printf %x $pagesize`
  local osize=`printf %x $oobsize`
  local nandrepeatedspl=$outputdir/spl-$ebsize-$psize-$osize.bin
  local padding=$tmpdir/padding
  local splpadding=$tmpdir/nand-spl-padding

  ${NAND_IMAGE_BUILDER} -c 64/1024 -p $pagesize -o $oobsize -u 1024 -e $eraseblocksize -b -s $spl $nandspl

  local splsize=`filesize $nandspl`
  local paddingsize=$((64-(splsize/(pagesize+oobsize))))
  local i=0

  while [ $i -lt $repeat ]; do
    dd if=/dev/urandom of=$padding bs=1024 count=$paddingsize
    ${NAND_IMAGE_BUILDER} -c 64/1024 -p $pagesize -o $oobsize -u 1024 -e $eraseblocksize -b -s $padding $splpadding
    cat $nandspl $splpadding > $nandpaddedspl

    if [ "$i" -eq "0" ]; then
      cat $nandpaddedspl > $nandrepeatedspl
    else
      cat $nandpaddedspl >> $nandrepeatedspl
    fi

    i=$((i+1))
  done

  rm -rf $tmpdir
}

# build the bootloader image
prepare_uboot() {
  local outputdir=$1
  local uboot=$2
  local eraseblocksize=$3
  local ebsize=`printf %x $eraseblocksize`
  local paddeduboot=$outputdir/uboot-$ebsize.bin

  dd if=$uboot of=$paddeduboot bs=$eraseblocksize conv=sync
}

## copy the source images in the output dir ##
mkdir -p $OUTPUT_DIR
cp $UBOOT_DIR/sunxi-spl.bin $OUTPUT_DIR/
cp $UBOOT_DIR/u-boot-dtb.bin $OUTPUT_DIR/

## prepare ubi images ##
# Toshiba SLC image:
#prepare_ubi $OUTPUTDIR $ROOTFSTAR "slc" 2048 262144 4096 1024
# Toshiba/Hynix MLC image:
#prepare_ubi $OUTPUTDIR $ROOTFSTAR "mlc" 4096 4194304 16384 16384

## prepare spl images ##
# Toshiba SLC image:
prepare_spl $OUTPUT_DIR $UBOOT_DIR/sunxi-spl.bin ${NAND_ERASE_BLOCK_SIZE} ${NAND_PAGE_SIZE} ${NAND_OOB_SIZE}
# Toshiba MLC image:
#prepare_spl $OUTPUTDIR $UBOOTDIR/spl/sunxi-spl.bin 4194304 16384 1280
# Hynix MLC image:
#prepare_spl $OUTPUTDIR $UBOOTDIR/spl/sunxi-spl.bin 4194304 16384 1664

## prepare uboot images ##
# Toshiba SLC image:
prepare_uboot $OUTPUT_DIR $UBOOT_DIR/u-boot-dtb.bin ${NAND_ERASE_BLOCK_SIZE}
# Toshiba/Hynix MLC image:
#prepare_uboot $OUTPUTDIR $UBOOTDIR/u-boot-dtb.bin 4194304
