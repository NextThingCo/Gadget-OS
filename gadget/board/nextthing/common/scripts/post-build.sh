#!/bin/bash

echo "##############################################################################"
echo "## $0 "
echo "##############################################################################"

# ROOT_DIR="$(pwd)"
ROOT_DIR="${BR2_EXTERNAL_GADGETOS_PATH}"
BOARD_DIR=${ROOT_DIR}/board/nextthing/chippro

MKIMAGE=${HOST_DIR}/usr/bin/mkimage

# ${MKIMAGE} -f ${BOARD_DIR}/bootimg.its ${BINARIES_DIR}/bootimg.itb

# cat <<-EOF >> ${TARGET_DIR}/etc/mdev.conf
# sd[a-z][0-9]* 0:0 0660 *(/opt/bin/automount $MDEV)
# mmcblk[0-9]p[0-9] 0:0 0660 *(/opt/bin/automount $MDEV)
# EOF

echo "TERM=xterm" | tee -a ${TARGET_DIR}/etc/profile
