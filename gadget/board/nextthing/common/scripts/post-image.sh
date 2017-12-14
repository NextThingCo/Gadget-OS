#!/bin/bash

NAND_CONFIG=$2

# Environment variables passed in from buildroot:
# BR2_CONFIG, HOST_DIR, STAGING_DIR, TARGET_DIR, BUILD_DIR, BINARIES_DIR and BASE_DIR.

echo "##############################################################################"
echo "## $0 "
echo "##############################################################################"

echo "# \$1 = $1"
echo "# \$2 = $2"

echo "# NAND_CONFIG = $NAND_CONFIG"
echo "# BR2_CONFIG=$BR2_CONFIG"
echo "# HOST_DIR=$HOST_DIR"
echo "# STAGING_DIR=$STAGING_DIR"
echo "# TARGET_DIR=$TARGET_DIR"
echo "# BUILD_DIR=$BUILD_DIR"
echo "# BINARIES_DIR=$BINARIES_DIR"
echo "# BASE_DIR=$BASE_DIR"

ROOT_DIR="${BR2_EXTERNAL_GADGETOS_PATH}"
BOARD_DIR=${ROOT_DIR}/board/nextthing/chippro

## create U-BOOT SCRIPT
mkimage -A arm -T script -C none -n "Flash" -d "${BOARD_DIR}/uboot.script.source" "${1}/uboot.script"

## create NAND images
pushd $BINARIES_DIR

echo "## creating SPL image"
"${HOST_DIR}/usr/bin/mk_chip_image" "${NAND_CONFIG}" spl sunxi-spl.bin spl-${NAND_CONFIG}.bin

echo "## creating uboot image"
"${HOST_DIR}/usr/bin/mk_chip_image" "${NAND_CONFIG}" u-boot u-boot-dtb.bin u-boot-${NAND_CONFIG}.bin

echo "## creating ubifs image"
"${HOST_DIR}/usr/bin/mk_chip_image" "${NAND_CONFIG}" ubifs rootfs_ro.tar rootfs.ubifs 

echo "## creating ubifs image"
"${HOST_DIR}/usr/bin/mk_chip_image" "${NAND_CONFIG}" ubifs data.tar data.ubifs 

echo "## creating ubi image"
"${HOST_DIR}/usr/bin/mk_chip_image" -c "${BOARD_DIR}/configs/ubinize.config" "${NAND_CONFIG}" ubi rootfs.ubifs ubi-${NAND_CONFIG}.bin

ln -sf "spl-${NAND_CONFIG}.bin" "$BINARIES_DIR/flash-spl.bin"
ln -sf "u-boot-${NAND_CONFIG}.bin" "$BINARIES_DIR/flash-uboot.bin"
ln -sf "ubi-${NAND_CONFIG}.bin.sparse" "$BINARIES_DIR/flash-rootfs.bin"

popd
