#!/bin/bash
FLASH_SPL=false
FLASH_UBOOT=false
BR_OUTPUT_DIR="${1}"
BOARD_DIR="${BOARD_DIR:-${BR_OUTPUT_DIR}/../gadget/board/nextthing/chippro}"

if [ "${2}" == "--continue" ]; then
	fastboot -i 0x1f3a continue
	exit 0
fi

if [ "${2}" == "--bootloader" ]; then
	FLASH_SPL=true
	FLASH_UBOOT=true

	sunxi-fel uboot ${BR_OUTPUT_DIR}/images/u-boot-sunxi-with-spl.bin write 0x43100000 ${BR_OUTPUT_DIR}/images/uboot.script
	sleep 8
fi

if $FLASH_SPL; then
	fastboot -i 0x1f3a erase spl
	fastboot -i 0x1f3a erase spl-backup
	fastboot -i 0x1f3a flash spl ${BR_OUTPUT_DIR}/images/flash-spl.bin
	fastboot -i 0x1f3a flash spl-backup ${BR_OUTPUT_DIR}/images/flash-spl.bin
fi

if $FLASH_UBOOT; then
	fastboot -i 0x1f3a erase uboot
	fastboot -i 0x1f3a flash uboot ${BR_OUTPUT_DIR}/images/flash-uboot.bin
fi

fastboot -i 0x1f3a erase UBI
fastboot -i 0x1f3a flash UBI ${BR_OUTPUT_DIR}/images/flash-rootfs.bin
fastboot -i 0x1f3a continue -u
